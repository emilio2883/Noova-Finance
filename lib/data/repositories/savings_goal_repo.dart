import 'package:isar/isar.dart';

import '../models/savings_goal.dart';

/// CRUD + contributions for savings goals.
class SavingsGoalRepository {
  final Isar _isar;
  SavingsGoalRepository(this._isar);

  Future<int> insert(SavingsGoal g) => _isar.writeTxn(() => _isar.savingsGoals.put(g));

  Future<void> update(SavingsGoal g) => _isar.writeTxn(() => _isar.savingsGoals.put(g));

  Future<void> delete(int id) => _isar.writeTxn(() => _isar.savingsGoals.delete(id));

  Future<SavingsGoal?> getById(int id) => _isar.savingsGoals.get(id);

  Future<List<SavingsGoal>> getAll() => _isar.savingsGoals.where().findAll();

  Future<List<SavingsGoal>> getActive() =>
      _isar.savingsGoals.filter().isActiveEqualTo(true).findAll();

  Future<void> addContribution(int id, int amountBps) async {
    final g = await getById(id);
    if (g == null) return;
    g.savedBps += amountBps;
    await update(g);
  }
}
