import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart' as x;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'dart:io';

import 'package:noova_finance/data/models/app_settings.dart';
import 'package:noova_finance/data/models/budget.dart';
import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/recurring_rule.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/repositories/category_repo.dart';
import 'package:noova_finance/data/repositories/transaction_repo.dart';
import 'package:noova_finance/data/services/excel_importer.dart';

void main() {
  late Isar isar;
  late TransactionRepository txnRepo;
  late CategoryRepository catRepo;
  late ExcelImporter importer;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    final dir = Directory.systemTemp;
    isar = await Isar.open(
      [
        TransactionSchema,
        CategorySchema,
        RecurringRuleSchema,
        BudgetSchema,
        AppSettingsSchema,
      ],
      directory: dir.path,
      name: 'test_importer_\${DateTime.now().millisecondsSinceEpoch}',
    );
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.transactions.clear();
      await isar.categorys.clear();
    });
    txnRepo = TransactionRepository(isar);
    catRepo = CategoryRepository(isar);
    await catRepo.seedDefaults();
    importer = ExcelImporter(txnRepo, catRepo);
  });

  /// Builds a small workbook mimicking the real structure.
  List<int> buildWorkbook() {
    final excel = x.Excel.createExcel();
    // Accessing by name auto-creates the sheet (Sheet1 also exists; the
    // importer filters sheets by the Y\d\d pattern so it is ignored).
    final sheet = excel['Y26'];

    // Row 1: months
    sheet.updateCell(x.CellIndex.indexByString('B1'), 'Enero');
    // Row 2: quincena headers
    sheet.updateCell(x.CellIndex.indexByString('B2'), '1-15');
    sheet.updateCell(x.CellIndex.indexByString('C2'), '15-30');

    // Row 3: Saldo Inicial
    sheet.updateCell(x.CellIndex.indexByString('A3'), 'Saldo Inicial');
    sheet.updateCell(x.CellIndex.indexByString('B3'), 1000.0);

    // Row 4: Salario (income)
    sheet.updateCell(x.CellIndex.indexByString('A4'), 'Salario');
    sheet.updateCell(x.CellIndex.indexByString('B4'), 2800.0);

    // Row 5: Restaurante (expense, negative in Excel)
    sheet.updateCell(x.CellIndex.indexByString('A5'), 'Restaurante');
    sheet.updateCell(x.CellIndex.indexByString('B5'), -150.50);

    // Row 6: group row (must be skipped)
    sheet.updateCell(x.CellIndex.indexByString('A6'), 'Alimentos');
    sheet.updateCell(x.CellIndex.indexByString('B6'), -150.50);

    final bytes = excel.save()!;
    return bytes;
  }

  test('imports income and expense rows with correct types', () async {
    final result = await importer.importBytes(buildWorkbook());
    expect(result.success, isTrue);
    expect(result.imported, 2); // Salario + Restaurante (Alimentos skipped)

    final all = await txnRepo.getAll();
    expect(all.length, 2);

    final salarioCat = await catRepo.getByImportKey('Salario');
    final salario = all.firstWhere(
      (t) => t.categoryId == salarioCat!.id,
      orElse: () => throw StateError('missing Salario'),
    );
    expect(salario.type, TransactionType.income);
    expect(salario.amount, Decimal.parse('2800.0'));
    expect(salario.date, DateTime(2026, 1, 1)); // quincena 1 -> day 1

    final restauranteCat = await catRepo.getByImportKey('Restaurante');
    final restaurante = all.firstWhere(
      (t) => t.categoryId == restauranteCat!.id,
      orElse: () => throw StateError('missing Restaurante'),
    );
    expect(restaurante.type, TransactionType.expense);
    expect(restaurante.amount, Decimal.parse('150.50'));
  });

  test('group rows are skipped (no double counting)', () async {
    final result = await importer.importBytes(buildWorkbook());
    expect(result.imported, 2);
    // No transaction with the Alimentos category directly from the group row
    final alimentosCat = await catRepo.getByImportKey('Alimentos');
    expect(alimentosCat, isNull); // Alimentos is not a leaf category
  });

  test('import is idempotent: re-import creates no duplicates', () async {
    final bytes = buildWorkbook();
    final first = await importer.importBytes(bytes);
    expect(first.imported, 2);

    final second = await importer.importBytes(bytes);
    expect(second.imported, 0);
    expect(second.skippedDuplicates, 2);

    final all = await txnRepo.getAll();
    expect(all.length, 2);
  });

  test('captures opening balance from Saldo Inicial', () async {
    final result = await importer.importBytes(buildWorkbook());
    expect(result.openingBalance, Decimal.parse('1000.0'));
  });
}
