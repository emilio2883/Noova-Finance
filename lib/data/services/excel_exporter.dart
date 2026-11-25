import 'package:decimal/decimal.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

import '../models/transaction.dart';
import '../repositories/category_repo.dart';
import '../repositories/transaction_repo.dart';

/// Exports all data to .xlsx with a structure similar to the original
/// Excel: one sheet per year, rows per category, columns per quincena.
class ExcelExporter {
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;

  ExcelExporter(this._transactionRepo, this._categoryRepo);

  /// Build the workbook bytes for all transactions.
  Future<List<int>> export() async {
    final transactions = await _transactionRepo.getAll();
    final categories = await _categoryRepo.getAll();
    final byId = {for (final c in categories) c.id: c};

    // Group by year
    final byYear = <int, List<Transaction>>{};
    for (final t in transactions) {
      byYear.putIfAbsent(t.date.year, () => []).add(t);
    }
    final years = byYear.keys.toList()..sort();

    final workbook = xls.Workbook();

    for (final year in years) {
      final sheet = workbook.worksheets.addWithName('Y${year % 100}');
      final txns = byYear[year]!;

      // Header: month names + quincena sub-headers (cols 2..25)
      const months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      sheet.getRangeByIndex(1, 2).setText(months[0]);
      sheet.getRangeByIndex(2, 2).setText('1-15');
      sheet.getRangeByIndex(2, 3).setText('15-30');
      var col = 4;
      for (var m = 1; m < 12; m++) {
        sheet.getRangeByIndex(1, col).setText(months[m]);
        sheet.getRangeByIndex(2, col).setText('1-15');
        sheet.getRangeByIndex(2, col + 1).setText('15-30');
        col += 2;
      }

      // Category rows
      final categoryIds = byId.keys.toList()..sort();
      var row = 4;
      final totalsPerQuincena = <int, Decimal>{};
      for (final catId in categoryIds) {
        final cat = byId[catId]!;
        final rowTxns = txns.where((t) => t.categoryId == catId).toList();
        if (rowTxns.isEmpty) continue;

        sheet.getRangeByIndex(row, 1).setText(cat.name);
        for (final t in rowTxns) {
          final quincena = t.date.day <= 15 ? 1 : 2;
          final colIndex = 2 + (t.date.month - 1) * 2 + (quincena - 1);
          final signed = t.type == TransactionType.income ? t.amount : -t.amount;
          final cell = sheet.getRangeByIndex(row, colIndex + 1);
          cell.setNumber(double.parse(signed.toString()));
          totalsPerQuincena[colIndex] =
              (totalsPerQuincena[colIndex] ?? Decimal.zero) + signed;
        }
        row++;
      }

      // Totals row
      sheet.getRangeByIndex(row, 1).setText('Total');
      for (final entry in totalsPerQuincena.entries) {
        sheet
            .getRangeByIndex(row, entry.key + 1)
            .setNumber(double.parse(entry.value.toString()));
      }
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    return bytes;
  }
}
