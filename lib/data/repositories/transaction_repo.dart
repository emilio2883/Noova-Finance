import 'package:decimal/decimal.dart';
import 'package:isar/isar.dart';

import '../models/transaction.dart';

/// CRUD + queries for transactions.
class TransactionRepository {
  final Isar _isar;
  TransactionRepository(this._isar);

  Future<int> insert(Transaction t) =>
      _isar.writeTxn(() => _isar.transactions.put(t));

  Future<List<int>> insertAll(List<Transaction> ts) =>
      _isar.writeTxn(() => _isar.transactions.putAll(ts));

  Future<void> update(Transaction t) =>
      _isar.writeTxn(() => _isar.transactions.put(t));

  Future<void> delete(int id) =>
      _isar.writeTxn(() => _isar.transactions.delete(id));

  /// Delete only this occurrence; recurring rules keep generating (spec edge case).
  Future<void> deleteOccurrence(Transaction t) =>
      _isar.writeTxn(() => _isar.transactions.delete(t.id));

  Future<Transaction?> getById(int id) => _isar.transactions.get(id);

  /// All transactions in [start, end] inclusive, newest first.
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) =>
      _isar.transactions
          .filter()
          .dateBetween(start, end)
          .sortByDateDesc()
          .findAll();

  /// Last [limit] transactions, newest first.
  Future<List<Transaction>> getRecent({int limit = 15}) =>
      _isar.transactions.where().sortByDateDesc().limit(limit).findAll();

  /// All transactions up to and including [date].
  Future<List<Transaction>> getUpTo(DateTime date) =>
      _isar.transactions.filter().dateLessThan(date, include: true).findAll();

  Future<List<Transaction>> getAll() =>
      _isar.transactions.where().findAll();

  /// True if a transaction with this import hash already exists (idempotency).
  Future<bool> existsByImportHash(String hash) =>
      _isar.transactions.filter().importHashEqualTo(hash).isNotEmpty();

  /// All transactions for a category in a period.
  Future<List<Transaction>> getByCategoryAndRange(
    int categoryId,
    DateTime start,
    DateTime end,
  ) =>
      _isar.transactions
          .filter()
          .categoryIdEqualTo(categoryId)
          .and()
          .dateBetween(start, end)
          .findAll();

  /// Total expenses for a category in a period (positive Decimal).
  Future<Decimal> totalByCategoryAndRange(
    int categoryId,
    DateTime start,
    DateTime end,
  ) async {
    final txns = await getByCategoryAndRange(categoryId, start, end);
    var total = Decimal.zero;
    for (final t in txns) {
      if (t.type == TransactionType.expense) total += t.amount;
    }
    return total;
  }

  /// Count of all transactions.
  Future<int> count() => _isar.transactions.count();
}
