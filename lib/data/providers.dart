import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'database.dart';
import 'repositories/budget_repo.dart';
import 'repositories/category_repo.dart';
import 'repositories/recurring_repo.dart';
import 'repositories/savings_goal_repo.dart';
import 'repositories/settings_repo.dart';
import 'repositories/transaction_repo.dart';
import 'services/budget_checker.dart';
import 'services/excel_exporter.dart';
import 'services/excel_importer.dart';
import 'services/recurring_generator.dart';
import 'services/saldo_calculator.dart';

/// Opens the Isar database lazily.
final isarProvider = FutureProvider<Isar>((ref) async {
  return AppDatabase.instance;
});

/// Repositories
final categoryRepoProvider = FutureProvider<CategoryRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  // No auto-seed: new users get categories from their imported file (or manual).
  return CategoryRepository(isar);
});

final transactionRepoProvider = FutureProvider<TransactionRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return TransactionRepository(isar);
});

final recurringRepoProvider = FutureProvider<RecurringRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return RecurringRepository(isar);
});

final budgetRepoProvider = FutureProvider<BudgetRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return BudgetRepository(isar);
});

final savingsGoalRepoProvider = FutureProvider<SavingsGoalRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SavingsGoalRepository(isar);
});

final settingsRepoProvider = FutureProvider<SettingsRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SettingsRepository(isar);
});

/// Services
final saldoCalculatorProvider = Provider<SaldoCalculator>((ref) {
  return SaldoCalculator();
});

final recurringGeneratorProvider = FutureProvider<RecurringGenerator>((ref) async {
  final recurringRepo = await ref.watch(recurringRepoProvider.future);
  final transactionRepo = await ref.watch(transactionRepoProvider.future);
  return RecurringGenerator(recurringRepo, transactionRepo);
});

final budgetCheckerProvider = FutureProvider<BudgetChecker>((ref) async {
  final budgetRepo = await ref.watch(budgetRepoProvider.future);
  final transactionRepo = await ref.watch(transactionRepoProvider.future);
  return BudgetChecker(budgetRepo, transactionRepo);
});

final excelImporterProvider = FutureProvider<ExcelImporter>((ref) async {
  final transactionRepo = await ref.watch(transactionRepoProvider.future);
  final categoryRepo = await ref.watch(categoryRepoProvider.future);
  return ExcelImporter(transactionRepo, categoryRepo);
});

final excelExporterProvider = FutureProvider<ExcelExporter>((ref) async {
  final transactionRepo = await ref.watch(transactionRepoProvider.future);
  final categoryRepo = await ref.watch(categoryRepoProvider.future);
  return ExcelExporter(transactionRepo, categoryRepo);
});
