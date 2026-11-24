import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'dart:io';

import 'package:noova_finance/data/models/app_settings.dart';
import 'package:noova_finance/data/models/budget.dart';
import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/recurring_rule.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/repositories/category_repo.dart';
import 'package:noova_finance/data/repositories/recurring_repo.dart';
import 'package:noova_finance/data/repositories/transaction_repo.dart';
import 'package:noova_finance/data/services/recurring_generator.dart';

void main() {
  late Isar isar;
  late RecurringRepository recurringRepo;
  late TransactionRepository txnRepo;
  late RecurringGenerator generator;
  late CategoryRepository catRepo;

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
      name: 'test_recurring_\${DateTime.now().millisecondsSinceEpoch}',
    );
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.transactions.clear();
      await isar.categorys.clear();
      await isar.recurringRules.clear();
    });
    recurringRepo = RecurringRepository(isar);
    txnRepo = TransactionRepository(isar);
    catRepo = CategoryRepository(isar);
    await catRepo.seedDefaults();
    generator = RecurringGenerator(recurringRepo, txnRepo);
  });

  test('generates a due quincenal rule transaction', () async {
    final cat = await catRepo.getByImportKey('Casa - Augusta/GG');
    final rule = RecurringRule(
      categoryId: cat!.id,
      amountBps: Decimal.parse('3280.00').shift(4).toBigInt().toInt(),
      frequency: RecurringFrequency.quincenal,
      activationDay: 1,
      startDate: DateTime(2026, 1, 1),
    );
    await recurringRepo.insert(rule);

    // Simulate: we're on Jan 2, rule was due on Jan 1
    final now = DateTime(2026, 1, 2);
    final generated = await generator.generateDue(now: now);

    expect(generated, 1);
    final txns = await txnRepo.getAll();
    expect(txns.length, 1);
    expect(txns.first.isRecurring, isTrue);
    expect(txns.first.recurringRuleId, rule.id);
    expect(txns.first.amount, Decimal.parse('3280.00'));
    expect(txns.first.date, DateTime(2026, 1, 1));
  });

  test('does not duplicate generation for the same period', () async {
    final cat = await catRepo.getByImportKey('Progreso');
    final rule = RecurringRule(
      categoryId: cat!.id,
      amountBps: Decimal.parse('150.00').shift(4).toBigInt().toInt(),
      frequency: RecurringFrequency.quincenal,
      activationDay: 1,
      startDate: DateTime(2026, 1, 1),
    );
    await recurringRepo.insert(rule);

    final now = DateTime(2026, 1, 2);
    await generator.generateDue(now: now);
    final second = await generator.generateDue(now: now);

    expect(second, 0);
    final txns = await txnRepo.getAll();
    expect(txns.length, 1);
  });

  test('inactive rules are not generated', () async {
    final cat = await catRepo.getByImportKey('Progreso');
    final rule = RecurringRule(
      categoryId: cat!.id,
      amountBps: Decimal.parse('150.00').shift(4).toBigInt().toInt(),
      frequency: RecurringFrequency.quincenal,
      activationDay: 1,
      startDate: DateTime(2026, 1, 1),
      isActive: false,
    );
    await recurringRepo.insert(rule);

    final generated = await generator.generateDue(now: DateTime(2026, 1, 2));
    expect(generated, 0);
  });

  test('rule not yet due (before activation day) generates nothing', () async {
    final cat = await catRepo.getByImportKey('Progreso');
    final rule = RecurringRule(
      categoryId: cat!.id,
      amountBps: Decimal.parse('150.00').shift(4).toBigInt().toInt(),
      frequency: RecurringFrequency.monthly,
      activationDay: 15,
      startDate: DateTime(2026, 1, 1),
    );
    await recurringRepo.insert(rule);

    final generated = await generator.generateDue(now: DateTime(2026, 1, 10));
    expect(generated, 0);
  });
}
