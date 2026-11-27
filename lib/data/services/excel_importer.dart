import 'package:decimal/decimal.dart';

import '../../core/utils/decimal_utils.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/category_repo.dart';
import '../repositories/transaction_repo.dart';
import 'xlsx_reader.dart';

class ImportResult {
  int imported = 0;
  int skippedDuplicates = 0;
  List<String> unknownRows = [];
  List<String> suggestedCategories = [];
  Decimal openingBalance = Decimal.zero;
  bool success = false;
  String? error;
}

/// Parses Estado Financiero workbooks into transactions.
/// - Matches row labels to categories by name/importKey (accent/case tolerant).
/// - Group rows (Casa, Impuestos, ...) are totals when their children are
///   present; otherwise their value is imported into the group category itself.
/// - For a brand-new user (empty category set) it *suggests* categories by
///   creating a tree from the file's group headers + rows.
class ExcelImporter {
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;
  String _source = '';

  ExcelImporter(this._transactionRepo, this._categoryRepo);

  /// Pure total/summary rows that are never data.
  static const Set<String> _skipRows = {
    'Saldo Final',
    'Gastos',
    'Utilidad Neta',
    'Total Ingresos',
    'Total Gastos',
    'Total Gasto NETO',
    'Total Ingreso NETO',
    'Ganancias o Perdida',
    'Ganancia Neta Anual',
    'Salario Mensual',
    'MasMovil',
    'Saldo Global TDC',
    'Trip Cost w/o Hotel & AirTicket',
  };

  static const Map<String, (String, TransactionType)> _knownGroups = {
    'ingresos': ('Ingresos', TransactionType.income),
    'impuestos': ('Impuestos', TransactionType.expense),
    'casa': ('Casa', TransactionType.expense),
    'seguro': ('Seguro', TransactionType.expense),
    'alimentos': ('Alimentos', TransactionType.expense),
    'carro': ('Carro', TransactionType.expense),
    'otros': ('Otros', TransactionType.expense),
    'prestamos': ('Prestamos', TransactionType.expense),
  };

  String _norm(String s) {
    var t = s.toLowerCase();
    const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n', 'ü': 'u'};
    accents.forEach((k, v) => t = t.replaceAll(k, v));
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }

  Future<ImportResult> importBytes(
    List<int> bytes, {
    String? sourceName,
    void Function(int sheet, int totalSheets)? onSheetDone,
  }) async {
    _source = sourceName ?? '';
    final result = ImportResult();
    try {
      final sheets = XlsxReader.parse(bytes);
      final sheetNames = sheets.keys
          .where((k) => RegExp(r'^Y\d{2}$').hasMatch(k))
          .toList()
        ..sort();

      var i = 0;
      for (final name in sheetNames) {
        final year = 2000 + int.parse(name.substring(1));
        await _importSheet(sheets[name]!, year, name, result);
        i++;
        onSheetDone?.call(i, sheetNames.length);
      }
      await _ensureOpeningBalance(result);
      result.success = true;
    } catch (e) {
      result.error = e.toString();
    }
    return result;
  }

  Future<void> _ensureOpeningBalance(ImportResult result) async {
    if (result.openingBalance == Decimal.zero) return;
    final hash = 'OPENING|$_source';
    if (await _transactionRepo.existsByImportHash(hash)) return;
    final cat = await _categoryRepo.getByImportKey('__saldo_inicial__');
    final catId = cat?.id ??
        await _categoryRepo.insert(Category(
          name: 'Saldo Inicial',
          type: TransactionType.income,
          isActive: false,
          importKey: '__saldo_inicial__',
          order: 0,
        ));
    await _transactionRepo.insert(Transaction(
      date: DateTime(2000, 1, 1),
      amountBps: DecimalUtils.toBps(result.openingBalance),
      type: TransactionType.income,
      categoryId: catId,
      description: 'Saldo inicial (importado)',
      importHash: hash,
    ));
  }

  Future<void> _importSheet(
    Map<int, Map<int, dynamic>> rows,
    int year,
    String sheetName,
    ImportResult result,
  ) async {
    final rowIdx = rows.keys.toList()..sort();

    int? headerRow;
    for (final r in rowIdx) {
      if (r > 10) break;
      final texts = rows[r]!.values.map((v) => v?.toString() ?? '');
      if (texts.any((t) => t.contains('1-15'))) {
        headerRow = r;
        break;
      }
    }
    if (headerRow == null) {
      throw FormatException('Sheet $sheetName: no quincena header row');
    }

    final columnMap = <int, (int, int)>{};
    final headerCells = rows[headerRow]!;
    final cols = headerCells.keys.toList()..sort();
    var occ = 0;
    for (final col in cols) {
      final text = headerCells[col]?.toString() ?? '';
      if (text.contains('1-15')) {
        columnMap[col] = ((occ ~/ 2) + 1, 1);
        occ++;
      } else if (text.contains('15-30')) {
        columnMap[col] = ((occ ~/ 2) + 1, 2);
        occ++;
      }
    }
    if (columnMap.isEmpty) {
      throw FormatException('Sheet $sheetName: no quincena columns');
    }

    final allCats = await _categoryRepo.getAll();
    final activeCats = allCats.where((c) => c.isActive).toList();
    final suggest = activeCats.isEmpty;

    final leavesByNorm = <String, int>{};
    final groupsByNorm = <String, int>{};
    final groupType = <int, TransactionType>{};
    final childNorms = <int, Set<String>>{};
    for (final c in allCats) {
      if (c.isGroup && c.parentId == null) {
        groupsByNorm[_norm(c.name)] = c.id;
        groupType[c.id] = c.type;
      } else {
        if (c.importKey != null) leavesByNorm[_norm(c.importKey!)] = c.id;
        leavesByNorm.putIfAbsent(_norm(c.name), () => c.id);
        if (c.parentId != null) {
          childNorms.putIfAbsent(c.parentId!, () => {});
          childNorms[c.parentId!]!.add(_norm(c.name));
          if (c.importKey != null) {
            childNorms[c.parentId!]!.add(_norm(c.importKey!));
          }
        }
      }
    }

    // Suggest mode: pre-create known group categories so rows nest under them.
    if (suggest) {
      for (final e in _knownGroups.entries) {
        if (groupsByNorm.containsKey(e.key)) continue;
        final g = Category(name: e.value.$1, type: e.value.$2)
          ..isGroup = true
          ..isActive = true
          ..order = 500;
        final id = await _categoryRepo.insert(g);
        groupsByNorm[e.key] = id;
        groupType[id] = e.value.$2;
      }
    }

    // Names present in data rows (for group-total detection).
    final present = <String>{};
    for (final r in rowIdx) {
      if (r <= headerRow) continue;
      final nm = _norm(_text(rows[r]![0]));
      if (nm.isNotEmpty) present.add(nm);
    }

    int? currentGroupId;
    TransactionType currentType = TransactionType.expense;
    final toInsert = <Transaction>[];

    for (final r in rowIdx) {
      if (r <= headerRow) continue;
      final cells = rows[r]!;
      if (cells.isEmpty) continue;
      final rowName = _text(cells[0]);
      if (rowName.isEmpty) continue;

      if (rowName == 'Saldo Inicial') {
        final first = _firstNumeric(cells, columnMap.keys.toList());
        if (first != null && result.openingBalance == Decimal.zero) {
          result.openingBalance = DecimalUtils.fromDouble(first);
        }
        continue;
      }
      final norm = _norm(rowName);
      if (_skipRows.contains(rowName)) continue;

      int? categoryId;
      if (groupsByNorm.containsKey(norm)) {
        final gid = groupsByNorm[norm]!;
        currentGroupId = gid;
        currentType = groupType[gid] ?? TransactionType.expense;
        final kids = childNorms[gid] ?? const <String>{};
        if (kids.any(present.contains)) {
          continue; // total row; children carry the data
        }
        categoryId = gid; // import group's own value
      } else if (leavesByNorm.containsKey(norm)) {
        categoryId = leavesByNorm[norm];
      } else if (suggest) {
        final type = currentGroupId != null
            ? (groupType[currentGroupId] ?? currentType)
            : currentType;
        final cat = Category(name: rowName, type: type)
          ..isGroup = false
          ..isVariable = true
          ..isActive = true
          ..order = 900
          ..importKey = rowName
          ..parentId = currentGroupId;
        categoryId = await _categoryRepo.insert(cat);
        leavesByNorm[norm] = categoryId;
        result.suggestedCategories.add(rowName);
        if (currentGroupId != null) {
          childNorms.putIfAbsent(currentGroupId, () => {}).add(norm);
        }
      } else {
        if (!result.unknownRows.contains(rowName)) {
          result.unknownRows.add(rowName);
        }
        continue;
      }

      final cat = await _categoryRepo.getById(categoryId!);
      if (cat == null) continue;
      final isIncome = cat.type == TransactionType.income;

      for (final entry in columnMap.entries) {
        final col = entry.key;
        final value = _num(cells[col]);
        if (value == null || value == 0) continue;
        final (month, quincena) = entry.value;
        final day = quincena == 1 ? 1 : 16;
        final amountBps = DecimalUtils.toBps(DecimalUtils.fromDouble(value.abs()));
        final hash = '$_source|$sheetName|$rowName|$col';
        toInsert.add(Transaction(
          date: DateTime(year, month, day),
          amountBps: amountBps,
          type: isIncome ? TransactionType.income : TransactionType.expense,
          categoryId: categoryId,
          description: 'Importado ($sheetName)',
          importHash: hash,
        ));
      }
    }

    for (final t in toInsert) {
      if (t.importHash != null &&
          await _transactionRepo.existsByImportHash(t.importHash!)) {
        result.skippedDuplicates++;
      } else {
        await _transactionRepo.insert(t);
        result.imported++;
      }
    }
  }

  String _text(dynamic v) => v == null ? '' : v.toString().trim();

  double? _num(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) {
      final cleaned = v.replaceAll(',', '').trim();
      if (cleaned.isEmpty) return null;
      return double.tryParse(cleaned);
    }
    return null;
  }

  double? _firstNumeric(Map<int, dynamic> cells, List<int> cols) {
    for (final col in cols) {
      final n = _num(cells[col]);
      if (n != null) return n;
    }
    return null;
  }
}
