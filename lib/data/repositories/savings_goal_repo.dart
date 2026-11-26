import 'package:isar/isar.dart';

import '../models/savings_contribution.dart';
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

  Future<void> addContribution(int id, int amountBps, {DateTime? date}) async {
    final g = await getById(id);
    if (g == null) return;
    await _isar.writeTxn(() async {
      await _isar.savingsContributions.put(SavingsContribution(
        goalId: id,
        amountBps: amountBps,
        date: date ?? DateTime.now(),
      ));
      g.savedBps += amountBps;
      await _isar.savingsGoals.put(g);
    });
  }

  Future<List<SavingsContribution>> getContributions(int goalId) =>
      _isar.savingsContributions
          .filter()
          .goalIdEqualTo(goalId)
          .sortByDateDesc()
          .findAll();

  Future<void> deleteContribution(int goalId, SavingsContribution c) async {
    final g = await getById(goalId);
    await _isar.writeTxn(() async {
      await _isar.savingsContributions.delete(c.id);
      if (g != null) {
        g.savedBps -= c.amountBps;
        if (g.savedBps < 0) g.savedBps = 0;
        await _isar.savingsGoals.put(g);
      }
    });
  }
}
