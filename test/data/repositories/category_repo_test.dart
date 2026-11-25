import 'package:isar/isar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

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
      name: 'test_category_\${DateTime.now().millisecondsSinceEpoch}',
    );
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.categorys.clear();
    });
    repo = CategoryRepository(isar);
  });

  test('seedDefaults builds the Categorias tab tree (8 groups + 26 leaves = 34)', () async {
    await repo.seedDefaults();
    final all = await repo.getAll();
    expect(all.length, 34);
    final groups = all.where((c) => c.isGroup).length;
    expect(groups, 8);
  });

  test('seedDefaults is idempotent', () async {
    await repo.seedDefaults();
    await repo.seedDefaults();
    final all = await repo.getAll();
    expect(all.length, 34);
  });

  test('getChildren returns subcategories of a principal', () async {
    await repo.seedDefaults();
    final casa = (await repo.getAll())
        .firstWhere((c) => c.name == 'Casa' && c.isGroup);
    final children = await repo.getChildren(casa.id);
    expect(children.length, 4);
    expect(children.map((c) => c.name), contains('Agua IDAAN'));
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
    expect(cat!.name, 'Hipoteca Augusta');
  });

  test('hide deactivates but keeps the record', () async {
    await repo.seedDefaults();
    final cat = await repo.getByImportKey('Lala');
    await repo.hide(cat!);
    final hidden = await repo.getById(cat.id);
    expect(hidden!.isActive, isFalse);
  });
}
