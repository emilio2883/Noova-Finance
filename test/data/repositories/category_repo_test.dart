import 'package:isar/isar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:noova_finance/data/models/app_settings.dart';
import 'package:noova_finance/data/models/budget.dart';
import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/recurring_rule.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/repositories/category_repo.dart';

void main() {
  late Isar isar;
  late CategoryRepository repo;

  setUpAll(() async {
    final dir = await getTemporaryDirectory();
    isar = await Isar.open(
      [
        TransactionSchema,
        CategorySchema,
        RecurringRuleSchema,
        BudgetSchema,
        AppSettingsSchema,
      ],
      directory: dir.path,
      name: 'test_category_\${DateTime.now().millisecondsSinceEpoch}',
    );
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.categorys.clear();
    });
    repo = CategoryRepository(isar);
  });

  test('seedDefaults inserts 26 categories on first run', () async {
    await repo.seedDefaults();
    final all = await repo.getAll();
    expect(all.length, 26);
  });

  test('seedDefaults is idempotent', () async {
    await repo.seedDefaults();
    await repo.seedDefaults();
    final all = await repo.getAll();
    expect(all.length, 26);
  });

  test('getActive filters by type and isActive', () async {
    await repo.seedDefaults();
    final income = await repo.getActive(TransactionType.income);
    expect(income.length, 2);
    expect(income.every((c) => c.type == TransactionType.income), isTrue);
  });

  test('getByImportKey finds by Excel row name', () async {
    await repo.seedDefaults();
    final cat = await repo.getByImportKey('Casa - Augusta/GG');
    expect(cat, isNotNull);
    expect(cat!.name, 'Casa Augusta/GG');
  });

  test('hide deactivates but keeps the record', () async {
    await repo.seedDefaults();
    final cat = await repo.getByImportKey('Lala');
    await repo.hide(cat!);
    final hidden = await repo.getById(cat.id);
    expect(hidden!.isActive, isFalse);
  });
}
