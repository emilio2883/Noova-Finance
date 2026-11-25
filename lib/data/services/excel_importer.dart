import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart' as x;

import '../../core/utils/decimal_utils.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/category_repo.dart';
import '../repositories/transaction_repo.dart';

/// Result of an import run.
class ImportResult {
  int imported = 0;
  int skippedDuplicates = 0;
  List<String> unknownRows = [];
  Decimal openingBalance = Decimal.zero;
  bool success = false;
  String? error;
}

/// Parses Estado Financiero-2.xlsx (sheets Y24/Y25/Y26) into transactions.
///
/// Excel structure (per sheet):
///   Row 0: month headers (Enero..Diciembre), each spanning 2 columns
///   Row 1: quincena sub-headers ("1-15", "15-30") x 12
///   Following rows: category rows. Group/total rows are SUMS of child rows
///   and MUST be skipped to avoid double-counting.
///
/// Idempotent: each cell gets hash "sheet|rowKey|colIndex"; re-import skips
/// existing hashes (spec FR-027).
class ExcelImporter {
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;

  ExcelImporter(this._transactionRepo, this._categoryRepo);

  /// Rows that are group sums, totals, or derived — never imported.
  static const Set<String> _skipRows = {
    'Saldo Inicial', // handled specially (opening balance)
    'Ingresos',
    'Gastos',
    'Utilidad Neta',
    'Total Ingresos',
    'Total Gastos',
    'Total Gasto NETO',
    'Impuestos Y Prestamos', // group = ISR + SS + SE
    'Total Ingreso NETO',
    'Ganancias o Perdida',
    'Ganancia Neta Anual',
    'Salario Mensual',
    'Casa', // group = Gas + IDAAN + Mant + Augusta/GG + playa + IFARHU
    'Seguro', // group = Progreso + MAFRE + PALIG + médico padres
    'Alimentos', // group = Restaurante + Supermercado
    'Carro', // group = Gasolina + PANAPASS
    'Otros', // group = Valeria + Lala + Viaje + Médicos + generales
    'MasMovil', // all zeros
    'Saldo Global TDC',
    'Trip Cost w/o Hotel & AirTicket',
  };

  /// Import the whole workbook. Returns per-sheet results.
  Future<ImportResult> importBytes(
    List<int> bytes, {
    void Function(int sheet, int totalSheets)? onSheetDone,
  }) async {
    final result = ImportResult();
    try {
      final excel = x.Excel.decodeBytes(bytes);
      final sheetNames = excel.tables.keys
          .where((k) => RegExp(r'^Y\d{2}$').hasMatch(k))
          .toList()
        ..sort();

      var sheetIndex = 0;
      for (final name in sheetNames) {
        final year = 2000 + int.parse(name.substring(1));
        final sheet = excel.tables[name];
        if (sheet == null) continue;
        await _importSheet(sheet, year, name, result);
        sheetIndex++;
        onSheetDone?.call(sheetIndex, sheetNames.length);
      }
      await _ensureOpeningBalance(result);
      result.success = true;
    } catch (e) {
      result.error = e.toString();
    }
    return result;
  }

  /// Creates a one-time opening-balance transaction so the historical saldo
  /// matches the Excel. Uses a hidden system category + idempotent hash.
  Future<void> _ensureOpeningBalance(ImportResult result) async {
    if (result.openingBalance == Decimal.zero) return;
    const hash = 'OPENING|initial';
    if (await _transactionRepo.existsByImportHash(hash)) return;

    var cat = await _categoryRepo.getByImportKey('__saldo_inicial__');
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
      description: 'Saldo inicial (importado del Excel)',
      importHash: hash,
    ));
  }

  Future<void> _importSheet(
    x.Sheet sheet,
    int year,
    String sheetName,
    ImportResult result,
  ) async {
    final rows = sheet.rows;

    // 1. Find the quincena header row (contains "1-15")
    int? quincenaHeaderRow;
    for (var r = 0; r < rows.length && r < 10; r++) {
      final cells = rows[r].map((c) => _cellText(c)).toList();
      if (cells.any((t) => t.contains('1-15'))) {
        quincenaHeaderRow = r;
        break;
      }
    }
    if (quincenaHeaderRow == null) {
      throw FormatException('Sheet $sheetName: no quincena header row found');
    }

    // 2. Build column -> (month, quincena) map from the header row
    final columnMap = <int, (int, int)>{}; // colIndex -> (month, quincena)
    var occurrence = 0;
    final headerCells = rows[quincenaHeaderRow];
    for (var c = 0; c < headerCells.length; c++) {
      final text = _cellText(headerCells[c]);
      if (text.contains('1-15')) {
        columnMap[c] = ((occurrence ~/ 2) + 1, 1);
        occurrence++;
      } else if (text.contains('15-30')) {
        columnMap[c] = ((occurrence ~/ 2) + 1, 2);
        occurrence++;
      }
    }
    if (columnMap.isEmpty) {
      throw FormatException('Sheet $sheetName: no quincena columns found');
    }

    // 3. Load categories by importKey
    final categoriesByKey = <String, int>{};
    for (final cat in await _categoryRepo.getAll()) {
      if (cat.importKey != null) categoriesByKey[cat.importKey!] = cat.id;
    }

    final toInsert = <Transaction>[];

    // 4. Scan data rows
    for (var r = quincenaHeaderRow + 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;
      final rowName = _cellText(row.first).trim();
      if (rowName.isEmpty) continue;

      // Opening balance: first Saldo Inicial value of the earliest sheet
      if (rowName == 'Saldo Inicial') {
        final firstValue = _firstNumeric(row, columnMap.keys.toList());
        if (firstValue != null && result.openingBalance == Decimal.zero) {
          result.openingBalance = DecimalUtils.fromDouble(firstValue);
        }
        continue;
      }
      if (_skipRows.contains(rowName)) continue;

      final categoryId = categoriesByKey[rowName];
      if (categoryId == null) {
        if (!result.unknownRows.contains(rowName)) {
          result.unknownRows.add(rowName);
        }
        continue;
      }

      // Determine type from the category
      final cat = await _categoryRepo.getById(categoryId);
      if (cat == null) continue;
      final isIncome = cat.type == TransactionType.income;

      for (final entry in columnMap.entries) {
        final col = entry.key;
        if (col >= row.length) continue;
        final cell = row[col];
        final value = _numericValue(cell);
        if (value == null || value == 0) continue;

        final (month, quincena) = entry.value;
        final day = quincena == 1 ? 1 : 16;
        final date = DateTime(year, month, day);
        final amountBps = DecimalUtils.toBps(DecimalUtils.fromDouble(value.abs()));

        final hash = '$sheetName|$rowName|$col';
        toInsert.add(Transaction(
          date: date,
          amountBps: amountBps,
          type: isIncome ? TransactionType.income : TransactionType.expense,
          categoryId: categoryId,
          description: 'Importado de Excel ($sheetName)',
          importHash: hash,
        ));
      }
    }

    // 5. Filter duplicates (idempotent import) and insert
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

  /// Cell text as trimmed string.
  String _cellText(x.Data? cell) {
    if (cell == null || cell.value == null) return '';
    return cell.value.toString().trim();
  }

  /// Numeric value of a cell, null if not numeric/empty.
  double? _numericValue(x.Data? cell) {
    if (cell == null || cell.value == null) return null;
    final v = cell.value;
    if (v is num) return v.toDouble();
    if (v is String) {
      final cleaned = v.trim().replaceAll(',', '');
      if (cleaned.isEmpty) return null;
      return double.tryParse(cleaned);
    }
    return null;
  }

  double? _firstNumeric(List<x.Data?> row, List<int> columns) {
    for (final col in columns) {
      if (col < row.length) {
        final v = _numericValue(row[col]);
        if (v != null) return v;
      }
    }
    return null;
  }
}
