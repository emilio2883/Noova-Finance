import 'package:decimal/decimal.dart';

import '../../core/utils/decimal_utils.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/category_repo.dart';
import '../repositories/transaction_repo.dart';
import 'xlsx_reader.dart';

/// Result of an import run.
class ImportResult {
  int imported = 0;
  int skippedDuplicates = 0;
  List<String> unknownRows = [];
  Decimal openingBalance = Decimal.zero;
  bool success = false;
  String? error;
}

/// Parses Estado Financiero workbooks into transactions.
///
/// Reads cached cell values (XlsxReader) so formulas/date formats are handled.
/// Idempotent per file: hash "source|sheet|row|col". Group/summary rows are
/// skipped so totals don't double-count.
class ExcelImporter {
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;

  /// Prefix (file name) in hashes so different files don't collide.
  String _source = '';

  ExcelImporter(this._transactionRepo, this._categoryRepo);

  /// Rows that are group sums, totals, or derived — never imported.
  static const Set<String> _skipRows = {
    'Saldo Inicial',
    'Saldo Final',
    'Ingresos',
    'Gastos',
    'Utilidad Neta',
    'Total Ingresos',
    'Total Gastos',
    'Total Gasto NETO',
    'Impuestos', // group (ISR + SS + SE)
    'Impuestos Y Prestamos', // legacy group name
    'Prestamos', // group row if present
    'Total Ingreso NETO',
    'Ganancias o Perdida',
    'Ganancia Neta Anual',
    'Salario Mensual',
    'Casa', // group
    'Seguro', // group
    'Alimentos', // group
    'Carro', // group
    'Otros', // group
    'MasMovil',
    'Saldo Global TDC',
    'Trip Cost w/o Hotel & AirTicket',
  };

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

    // 1. Find the quincena header row (a row containing "1-15").
    int? headerRow;
    for (final r in rowIdx) {
      if (r > 10) break;
      final cells = rows[r]!;
      final texts = cells.values.map((v) => v?.toString() ?? '');
      if (texts.any((t) => t.contains('1-15'))) {
        headerRow = r;
        break;
      }
    }
    if (headerRow == null) {
      throw FormatException('Sheet $sheetName: no quincena header row');
    }

    // 2. Column -> (month, quincena)
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

    // 3. Categories by importKey
    final categoriesByKey = <String, int>{};
    for (final cat in await _categoryRepo.getAll()) {
      if (cat.importKey != null) categoriesByKey[cat.importKey!] = cat.id;
    }

    final toInsert = <Transaction>[];

    // 4. Scan data rows
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
      if (_skipRows.contains(rowName)) continue;

      final categoryId = categoriesByKey[rowName];
      if (categoryId == null) {
        if (!result.unknownRows.contains(rowName)) result.unknownRows.add(rowName);
        continue;
      }
      final cat = await _categoryRepo.getById(categoryId);
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

    // 5. Insert, skipping duplicates
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
