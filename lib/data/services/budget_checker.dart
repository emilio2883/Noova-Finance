import '../../core/utils/date_utils.dart';
import '../../core/utils/decimal_utils.dart';
import '../models/budget.dart';
import '../repositories/budget_repo.dart';
import '../repositories/transaction_repo.dart';

/// Status of a category budget for the current quincena.
class BudgetStatus {
  final Budget budget;
  final int categoryId;
  final bool warning; // >= threshold
  final bool exceeded; // >= 100%
  final int percentUsed;

  BudgetStatus({
    required this.budget,
    required this.categoryId,
    required this.warning,
    required this.exceeded,
    required this.percentUsed,
  });
}

/// Checks budget thresholds after each expense (spec FR-016/FR-017).
class BudgetChecker {
  final BudgetRepository _budgetRepo;
  final TransactionRepository _transactionRepo;

  BudgetChecker(this._budgetRepo, this._transactionRepo);

  /// Check all active budgets for the quincena containing [now].
  /// Returns statuses that crossed their threshold since last check.
  Future<List<BudgetStatus>> checkQuincena({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final start = QuincenaUtils.quincenaStart(today);
    final end = QuincenaUtils.quincenaEnd(today);
    final budgets = await _budgetRepo.getActive();

    final alerts = <BudgetStatus>[];
    for (final b in budgets) {
      final spent = await _transactionRepo.totalByCategoryAndRange(
        b.categoryId,
        start,
        end,
      );
      if (b.amountPerQuincenaBps == 0) continue;
      final percent =
          (spent.shift(4).toBigInt().toInt() * 100) ~/ b.amountPerQuincenaBps;

      final exceeded = percent >= 100;
      final warning = !exceeded && percent >= b.alertThreshold;
      if (exceeded || warning) {
        alerts.add(BudgetStatus(
          budget: b,
          categoryId: b.categoryId,
          warning: warning,
          exceeded: exceeded,
          percentUsed: percent,
        ));
      }
    }
    return alerts;
  }

  /// Suggest a budget for a category from historical average spending
  /// per quincena (spec FR-021).
  Future<int> suggestFromHistory(
    int categoryId,
    List<DateTime> quincenaStarts,
  ) async {
    if (quincenaStarts.isEmpty) return 0;
    var total = 0;
    for (final start in quincenaStarts) {
      final end = QuincenaUtils.quincenaEnd(start);
      final spent = await _transactionRepo.totalByCategoryAndRange(
        categoryId,
        start,
        end,
      );
      total += spent.shift(4).toBigInt().toInt();
    }
    return total ~/ quincenaStarts.length;
  }
}
