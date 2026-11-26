import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers.dart';
import '../../../data/services/saldo_calculator.dart';

/// Spending + budget for a subcategory.
class ChildSpend {
  final Category category;
  final Decimal spent;
  final Decimal budget; // 0 if none
  ChildSpend({required this.category, required this.spent, required this.budget});

  int get percentUsed {
    if (budget == Decimal.zero) return 0;
    return (spent.shift(4).toBigInt().toInt() * 100) ~/
        budget.shift(4).toBigInt().toInt();
  }
}

/// Spending + budget rollup for a principal category.
class CategorySpend {
  final Category parent;
  final Decimal total;
  final Decimal budget;
  final List<ChildSpend> children;

  CategorySpend({
    required this.parent,
    required this.total,
    required this.budget,
    required this.children,
  });

  int get percentUsed {
    if (budget == Decimal.zero) return 0;
    return (total.shift(4).toBigInt().toInt() * 100) ~/
        budget.shift(4).toBigInt().toInt();
  }

  bool get hasBudget => budget > Decimal.zero;
}

/// Aggregated dashboard state.
class DashboardData {
  final Decimal saldo;
  final Decimal ingresosMes;
  final Decimal gastosMes;
  final Decimal utilidadMes;
  final Decimal ingresosAnio;
  final Decimal gastosAnio;
  final Decimal utilidadAnio;
  final List<CategorySpend> categorySpending; // sorted desc by total
  final Decimal globalBudget;
  final Decimal globalSpent; // spent within budgeted categories this quincena
  final List<Transaction> recent;

  DashboardData({
    required this.saldo,
    required this.ingresosMes,
    required this.gastosMes,
    required this.utilidadMes,
    required this.ingresosAnio,
    required this.gastosAnio,
    required this.utilidadAnio,
    required this.categorySpending,
    required this.globalBudget,
    required this.globalSpent,
    required this.recent,
  });
}

/// Recomputes on every mutation.
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final txnRepo = await ref.watch(transactionRepoProvider.future);
  final catRepo = await ref.watch(categoryRepoProvider.future);
  final budgetRepo = await ref.watch(budgetRepoProvider.future);

  final now = DateTime.now();
  final all = await txnRepo.getAll();
  final monthStart = QuincenaUtils.monthStart(now);
  final monthEnd = QuincenaUtils.monthEnd(now);
  final yStart = QuincenaUtils.yearStart(now);
  final yEnd = QuincenaUtils.yearEnd(now);
  final qStart = QuincenaUtils.quincenaStart(now);
  final qEnd = QuincenaUtils.quincenaEnd(now);

  final budgets = await budgetRepo.getActive();
  final budgetByCat = <int, Decimal>{
    for (final b in budgets) b.categoryId: b.amountPerQuincena
  };

  // Expense totals per category for the current quincena.
  final spentByCat = SaldoCalculator.gastosPorCategoria(all, qStart, qEnd);

  // Build principal rollups.
  final principals = await catRepo.getTopLevel(TransactionType.expense);
  final categorySpending = <CategorySpend>[];
  Decimal globalBudget = Decimal.zero;
  Decimal globalSpent = Decimal.zero;

  for (final p in principals) {
    final children = await catRepo.getChildren(p.id);
    final childSpends = <ChildSpend>[];
    var total = spentByCat[p.id] ?? Decimal.zero;
    var budgetTotal = Decimal.zero;

    for (final child in children) {
      final spent = spentByCat[child.id] ?? Decimal.zero;
      final budget = budgetByCat[child.id] ?? Decimal.zero;
      childSpends.add(ChildSpend(category: child, spent: spent, budget: budget));
      total += spent;
      budgetTotal += budget;
      if (budget > Decimal.zero) {
        globalBudget += budget;
        globalSpent += spent;
      }
    }
    // Budget can also be set directly on the principal
    final parentBudget = budgetByCat[p.id] ?? Decimal.zero;
    if (parentBudget > Decimal.zero) {
      budgetTotal += parentBudget;
      globalBudget += parentBudget;
      globalSpent += spentByCat[p.id] ?? Decimal.zero;
    }

    categorySpending.add(CategorySpend(
      parent: p,
      total: total,
      budget: budgetTotal,
      children: childSpends,
    ));
  }

  // Dynamic ordering: highest spending first.
  categorySpending.sort((a, b) => b.total.compareTo(a.total));

  final recent = await txnRepo.getRecent(limit: 15);

  return DashboardData(
    saldo: SaldoCalculator.saldo(all, now),
    ingresosMes: SaldoCalculator.ingresos(all, monthStart, monthEnd),
    gastosMes: SaldoCalculator.gastos(all, monthStart, monthEnd),
    utilidadMes: SaldoCalculator.utilidad(all, monthStart, monthEnd),
    ingresosAnio: SaldoCalculator.ingresos(all, yStart, yEnd),
    gastosAnio: SaldoCalculator.gastos(all, yStart, yEnd),
    utilidadAnio: SaldoCalculator.utilidad(all, yStart, yEnd),
    categorySpending: categorySpending,
    globalBudget: globalBudget,
    globalSpent: globalSpent,
    recent: recent,
  );
});

/// Invalidate the dashboard after any mutation.
void refreshDashboard(Ref ref) {
  ref.invalidate(dashboardProvider);
}
