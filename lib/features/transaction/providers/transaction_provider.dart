import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(ref);
});
