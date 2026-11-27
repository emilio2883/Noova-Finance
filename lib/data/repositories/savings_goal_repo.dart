import 'package:isar/isar.dart';

import '../models/savings_contribution.dart';
import '../models/savings_goal.dart';

/// CRUD + contributions for savings goals.
class SavingsGoalRepository {
  final Isar _isar;
  SavingsGoalRepository(this._isar);

  Future<int> insert(SavingsGoal g) => _isar.writeTxn(() => _isar.savingsGoals.put(g));

  Future<void> update(SavingsGoal g) => _isar.writeTxn(() => _isar.savingsGoals.put(g));

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.savingsContributions.filter().goalIdEqualTo(id).deleteAll();
      await _isar.savingsGoals.delete(id);
    });
  }

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

  /// Auto-generate monthly contributions for recurring goals up to [now].
  Future<int> generateRecurring({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final nowKey = today.year * 100 + today.month;
    final goals = await getActive();
    var count = 0;
    for (final g in goals) {
      if (!g.isRecurring || g.periodMonths <= 0) continue;
      final monthlyBps = g.targetBps ~/ g.periodMonths;
      if (monthlyBps <= 0) continue;
      var y = 0, m = 0;
      if (g.lastAutoMonth == 0) {
        y = today.year;
        m = today.month;
      } else {
        y = g.lastAutoMonth ~/ 100;
        m = g.lastAutoMonth % 100;
        m++;
        if (m > 12) {
          m = 1;
          y++;
        }
      }
      while (y * 100 + m <= nowKey) {
        await addContribution(g.id, monthlyBps, date: DateTime(y, m, 1));
        count++;
        m++;
        if (m > 12) {
          m = 1;
          y++;
        }
      }
      final fresh = await getById(g.id);
      if (fresh != null) {
        fresh.lastAutoMonth = nowKey;
        await update(fresh);
      }
    }
    return count;
  }

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
