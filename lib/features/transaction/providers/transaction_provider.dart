import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers.dart';
import '../../dashboard/providers/dashboard_provider.dart';

/// Mutation handlers for transactions.
class TransactionService {
  final Ref _ref;
  TransactionService(this._ref);

  Future<void> insert({
    required DateTime date,
    required Decimal amount,
    required TransactionType type,
    required int categoryId,
    String? description,
  }) async {
    final repo = await _ref.read(transactionRepoProvider.future);
    await repo.insert(Transaction(
      date: date,
      amountBps: amount.shift(4).toBigInt().toInt(),
      type: type,
      categoryId: categoryId,
      description: description,
    ));
    refreshDashboard(_ref);

    // Budget alert hook (T050): check thresholds after each expense.
    if (type == TransactionType.expense) {
      await _checkBudgets(categoryId);
    }
  }

  Future<void> update(Transaction t) async {
    final repo = await _ref.read(transactionRepoProvider.future);
    await repo.update(t);
    refreshDashboard(_ref);
  }

  Future<void> delete(int id) async {
    final repo = await _ref.read(transactionRepoProvider.future);
    await repo.delete(id);
    refreshDashboard(_ref);
  }

  /// Check budgets and fire a notification if the inserted expense
  /// crossed a threshold (spec FR-016/FR-017).
  Future<void> _checkBudgets(int categoryId) async {
    try {
      final checker = await _ref.read(budgetCheckerProvider.future);
      final alerts = await checker.checkQuincena();
      final categoryAlerts =
          alerts.where((a) => a.categoryId == categoryId).toList();
      for (final alert in categoryAlerts) {
        final catRepo = await _ref.read(categoryRepoProvider.future);
        final cat = await catRepo.getById(alert.categoryId);
        final name = cat?.name ?? 'Categoría';
        if (alert.exceeded) {
          await NotificationService.show(
            id: 100 + alert.categoryId,
            title: 'Presupuesto excedido',
            body:
                '$name: ${alert.percentUsed}% del presupuesto quincenal usado.',
          );
        } else {
          await NotificationService.show(
            id: 100 + alert.categoryId,
            title: 'Alerta de presupuesto',
            body:
                '$name: ${alert.percentUsed}% del presupuesto quincenal usado.',
          );
        }
      }
    } catch (_) {
      // Budget check is best-effort: never block transaction saving.
    }
  }
}

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(ref);
});
