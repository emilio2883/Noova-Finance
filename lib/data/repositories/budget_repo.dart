import 'package:isar/isar.dart';

import '../models/budget.dart';

/// CRUD for budgets.
class BudgetRepository {
  final Isar _isar;
  BudgetRepository(this._isar);

  Future<int> insert(Budget b) => _isar.writeTxn(() => _isar.budgets.put(b));

  Future<void> update(Budget b) => _isar.writeTxn(() => _isar.budgets.put(b));

  Future<void> deactivate(Budget b) async {
    b.isActive = false;
    await _isar.writeTxn(() => _isar.budgets.put(b));
  }

  Future<void> delete(int id) => _isar.writeTxn(() => _isar.budgets.delete(id));

  Future<Budget?> getById(int id) => _isar.budgets.get(id);

  Future<Budget?> getByCategory(int categoryId) =>
      _isar.budgets.filter().categoryIdEqualTo(categoryId).findFirst();

  Future<List<Budget>> getAll() => _isar.budgets.where().findAll();

  Future<List<Budget>> getActive() =>
      _isar.budgets.filter().isActiveEqualTo(true).findAll();
}
