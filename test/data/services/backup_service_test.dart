import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:noova_finance/data/models/app_settings.dart';
import 'package:noova_finance/data/models/budget.dart';
import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/recurring_rule.dart';
import 'package:noova_finance/data/models/savings_contribution.dart';
import 'package:noova_finance/data/models/savings_goal.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/services/backup_service.dart';

void main() {
  late Isar isar;
  late BackupService backup;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [
        TransactionSchema,
        CategorySchema,
        BudgetSchema,
        RecurringRuleSchema,
        SavingsGoalSchema,
        SavingsContributionSchema,
        AppSettingsSchema,
      ],
      directory: Directory.systemTemp.path,
      name: 'backup_test_${DateTime.now().millisecondsSinceEpoch}',
    );
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.transactions.clear();
      await isar.categorys.clear();
      await isar.budgets.clear();
      await isar.recurringRules.clear();
      await isar.savingsGoals.clear();
      await isar.savingsContributions.clear();
      await isar.appSettings.clear();
    });
    backup = BackupService(isar);
  });

  test('backup -> restore reconstructs identical data', () async {
    final catId = await isar.writeTxn(() => isar.categorys.put(
        Category(name: 'Gas', type: TransactionType.expense)..isGroup = false));
    final goalId = await isar.writeTxn(() => isar.savingsGoals.put(
        SavingsGoal(name: 'Viaje', targetBps: 1000000, savedBps: 250000)));
    await isar.writeTxn(() async {
      await isar.transactions.put(Transaction(
        date: DateTime(2026, 1, 5),
        amountBps: 15050,
        type: TransactionType.expense,
        categoryId: catId,
        description: 'Gas enero',
      ));
      await isar.budgets.put(Budget(categoryId: catId, amountPerQuincenaBps: 50000));
      await isar.recurringRules.put(RecurringRule(
        categoryId: catId,
        amountBps: 9999,
        frequency: RecurringFrequency.monthly,
        activationDay: 5,
        startDate: DateTime(2026, 1, 1),
        label: 'Netflix',
        isSubscription: true,
      ));
      await isar.savingsContributions.put(SavingsContribution(
          goalId: goalId, amountBps: 250000, date: DateTime(2026, 1, 10)));
      await isar.appSettings.put(AppSettings(userName: 'Erick')..id = 0);
    });

    final json = await backup.exportJson();
    final origTx = await isar.transactions.count();

    // Mutate: add extra transaction + change settings.
    await isar.writeTxn(() async {
      await isar.transactions.put(Transaction(
        date: DateTime(2026, 2, 1),
        amountBps: 1,
        type: TransactionType.expense,
        categoryId: catId,
      ));
    });
    expect(await isar.transactions.count(), origTx + 1);

    await backup.restoreJson(json);

    expect(await isar.transactions.count(), origTx);
    expect(await isar.categorys.count(), 1);
    expect(await isar.budgets.count(), 1);
    expect(await isar.recurringRules.count(), 1);
    expect(await isar.savingsGoals.count(), 1);
    expect(await isar.savingsContributions.count(), 1);
    final s = await isar.appSettings.get(0);
    expect(s?.userName, 'Erick');
    final rule = (await isar.recurringRules.where().findAll()).first;
    expect(rule.label, 'Netflix');
    expect(rule.isSubscription, isTrue);
  });

  test('restore rejects invalid snapshot', () async {
    expect(() => backup.restoreJson('{"foo":1}'), throwsA(isA<FormatException>()));
  });
}
