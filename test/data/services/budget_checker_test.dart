import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'dart:io';

import 'package:noova_finance/data/models/app_settings.dart';
import 'package:noova_finance/data/models/budget.dart';
import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/recurring_rule.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/repositories/budget_repo.dart';
import 'package:noova_finance/data/repositories/category_repo.dart';
import 'package:noova_finance/data/repositories/transaction_repo.dart';
import 'package:noova_finance/data/services/budget_checker.dart';

void main() {
  late Isar isar;
  late BudgetRepository budgetRepo;
  late TransactionRepository txnRepo;
  late CategoryRepository catRepo;
  late BudgetChecker checker;

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
      name: 'test_budget_\${DateTime.now().millisecondsSinceEpoch}',
    );
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.transactions.clear();
      await isar.categorys.clear();
      await isar.budgets.clear();
    });
    budgetRepo = BudgetRepository(isar);
    txnRepo = TransactionRepository(isar);
    catRepo = CategoryRepository(isar);
    await catRepo.seedDefaults();
    checker = BudgetChecker(budgetRepo, txnRepo);
  });

  Future<void> addExpense(int categoryId, String amount, DateTime date) async {
    await txnRepo.insert(Transaction(
      date: date,
      amountBps: Decimal.parse(amount).shift(4).toBigInt().toInt(),
      type: TransactionType.expense,
      categoryId: categoryId,
    ));
  }

  test('alerts at 80% threshold (warning)', () async {
    final cat = await catRepo.getByImportKey('Restaurante');
    await budgetRepo.insert(Budget(
      categoryId: cat!.id,
      amountPerQuincenaBps: Decimal.parse('400.00').shift(4).toBigInt().toInt(),
      alertThreshold: 80,
    ));

    // Spend 320 of 400 = 80%
    await addExpense(cat.id, '320.00', DateTime(2026, 11, 5));

    final alerts = await checker.checkQuincena(now: DateTime(2026, 11, 10));
    expect(alerts.length, 1);
    expect(alerts.first.warning, isTrue);
    expect(alerts.first.exceeded, isFalse);
    expect(alerts.first.percentUsed, 80);
  });

  test('alerts exceeded at 100%+', () async {
    final cat = await catRepo.getByImportKey('Restaurante');
    await budgetRepo.insert(Budget(
      categoryId: cat!.id,
      amountPerQuincenaBps: Decimal.parse('400.00').shift(4).toBigInt().toInt(),
    ));

    await addExpense(cat.id, '450.00', DateTime(2026, 11, 5));

    final alerts = await checker.checkQuincena(now: DateTime(2026, 11, 10));
    expect(alerts.length, 1);
    expect(alerts.first.exceeded, isTrue);
  });

  test('no alert below threshold', () async {
    final cat = await catRepo.getByImportKey('Restaurante');
    await budgetRepo.insert(Budget(
      categoryId: cat!.id,
      amountPerQuincenaBps: Decimal.parse('400.00').shift(4).toBigInt().toInt(),
    ));

    await addExpense(cat.id, '100.00', DateTime(2026, 11, 5));

    final alerts = await checker.checkQuincena(now: DateTime(2026, 11, 10));
    expect(alerts, isEmpty);
  });

  test('only counts expenses in the current quincena', () async {
    final cat = await catRepo.getByImportKey('Restaurante');
    await budgetRepo.insert(Budget(
      categoryId: cat!.id,
      amountPerQuincenaBps: Decimal.parse('400.00').shift(4).toBigInt().toInt(),
    ));

    // Expense in the PREVIOUS quincena (Oct 16-30)
    await addExpense(cat.id, '350.00', DateTime(2026, 10, 20));

    final alerts = await checker.checkQuincena(now: DateTime(2026, 11, 10));
    expect(alerts, isEmpty);
  });
}
