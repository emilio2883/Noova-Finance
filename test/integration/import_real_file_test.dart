import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:noova_finance/data/models/app_settings.dart';
import 'package:noova_finance/data/models/budget.dart';
import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/import_record.dart';
import 'package:noova_finance/data/models/recurring_rule.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/repositories/category_repo.dart';
import 'package:noova_finance/data/repositories/transaction_repo.dart';
import 'package:noova_finance/data/services/excel_importer.dart';

/// Local verification against the user's real test workbook.
/// Skipped automatically if the file is not present on this machine.
void main() {
  const path = 'D:/Noova Finance/NOOVA Estado Financiero - TEST.xlsx';

  test('imports the real TEST file and maps categories correctly', () async {
    if (!File(path).existsSync()) {
      // ignore: avoid_print
      print('SKIP: test workbook not found at $path');
      return;
    }

    await Isar.initializeIsarCore(download: true);
    final isar = await Isar.open(
      [
        TransactionSchema,
        CategorySchema,
        RecurringRuleSchema,
        BudgetSchema,
        AppSettingsSchema,
        ImportRecordSchema,
      ],
      directory: Directory.systemTemp.path,
      name: 'test_real_${DateTime.now().millisecondsSinceEpoch}',
    );

    final catRepo = CategoryRepository(isar);
    await catRepo.seedDefaults();
    final txnRepo = TransactionRepository(isar);
    final importer = ExcelImporter(txnRepo, catRepo);

    final res = await importer.importBytes(
      File(path).readAsBytesSync(),
      sourceName: 'TEST.xlsx',
    );

    // ignore: avoid_print
    print('IMPORT RESULT: imported=${res.imported} '
        'skipped=${res.skippedDuplicates} opening=${res.openingBalance} '
        'unknown=${res.unknownRows} success=${res.success} err=${res.error}');

    expect(res.success, isTrue, reason: res.error ?? '');
    expect(res.imported, greaterThan(100));
    expect(res.openingBalance, Decimal.parse('107652.2599'));

    // Mapping checks: data row -> renamed category
    final idaan = await catRepo.getByImportKey('IDAAN');
    final hipoteca = await catRepo.getByImportKey('Casa - Augusta/GG');
    final qlu = await catRepo.getByImportKey('QLU MBA - IFARHU');
    // ignore: avoid_print
    print('IDAAN->${idaan?.name}, Casa-Augusta->${hipoteca?.name}, QLU->${qlu?.name}');
    expect(idaan?.name, 'Agua IDAAN');
    expect(hipoteca?.name, 'Hipoteca Augusta');
    expect(qlu?.name, 'QLU MBA - IFARHU');

    // Hipoteca Augusta must sit under Prestamos
    final prestamos = (await catRepo.getAll())
        .firstWhere((c) => c.name == 'Prestamos' && c.isGroup);
    expect(hipoteca?.parentId, prestamos.id);

    final total = await txnRepo.count();
    // ignore: avoid_print
    print('TOTAL TXNS: $total');
    await isar.close();
  }, timeout: const Timeout(Duration(minutes: 3)));
}
