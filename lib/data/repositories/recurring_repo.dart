import 'package:isar/isar.dart';

import '../models/recurring_rule.dart';

/// CRUD + due-rule queries for recurring rules.
class RecurringRepository {
  final Isar _isar;
  RecurringRepository(this._isar);

  Future<int> insert(RecurringRule r) =>
      _isar.writeTxn(() => _isar.recurringRules.put(r));

  Future<void> update(RecurringRule r) =>
      _isar.writeTxn(() => _isar.recurringRules.put(r));

  Future<void> deactivate(RecurringRule r) async {
    r.isActive = false;
    await _isar.writeTxn(() => _isar.recurringRules.put(r));
  }

  Future<void> delete(int id) =>
      _isar.writeTxn(() => _isar.recurringRules.delete(id));

  Future<RecurringRule?> getById(int id) => _isar.recurringRules.get(id);

  Future<List<RecurringRule>> getAll() =>
      _isar.recurringRules.where().findAll();

  Future<List<RecurringRule>> getActive() =>
      _isar.recurringRules.filter().isActiveEqualTo(true).findAll();

  /// Rules that are due for generation as of [now]:
  /// active, started, not ended, and lastGenerated before the current period.
  Future<List<RecurringRule>> findDue(DateTime now) async {
    final active = await getActive();
    return active.where((r) {
      if (r.startDate.isAfter(now)) return false;
      if (r.endDate != null && r.endDate!.isBefore(now)) return false;
      // Due if we've passed the activation day of the current period
      // and lastGenerated hasn't covered it yet.
      final last = r.lastGenerated ?? r.startDate;
      final nowPeriod = _periodKey(now, r.frequency);
      final lastPeriod = _periodKey(last, r.frequency);
      return nowPeriod != lastPeriod && now.day >= _effectiveDay(now, r.activationDay);
    }).toList();
  }

  int _periodKey(DateTime d, RecurringFrequency f) {
    if (f == RecurringFrequency.monthly) return d.year * 100 + d.month;
    // quincenal: year*1000 + month*10 + quincenaNumber
    final q = d.day <= 15 ? 1 : 2;
    return d.year * 1000 + d.month * 10 + q;
  }

  int _effectiveDay(DateTime now, int activationDay) {
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return activationDay > lastDay ? lastDay : activationDay;
  }
}
