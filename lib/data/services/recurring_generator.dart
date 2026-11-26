import '../models/recurring_rule.dart';
import '../models/transaction.dart';
import '../repositories/recurring_repo.dart';
import '../repositories/transaction_repo.dart';

/// Auto-generates transactions for due recurring rules (spec FR-010).
/// Runs on app startup; generates any overdue occurrences.
class RecurringGenerator {
  final RecurringRepository _recurringRepo;
  final TransactionRepository _transactionRepo;

  RecurringGenerator(this._recurringRepo, this._transactionRepo);

  /// Generate all due transactions as of [now]. Returns count generated.
  Future<int> generateDue({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final dueRules = await _recurringRepo.findDue(today);
    var generated = 0;

    for (final rule in dueRules) {
      final date = _occurrenceDate(rule, today);
      if (date == null) continue;

      // Avoid duplicates: same rule, same date already generated?
      final existing = await _transactionRepo.getByDateRange(
        DateTime(date.year, date.month, date.day),
        DateTime(date.year, date.month, date.day, 23, 59, 59, 999),
      );
      final alreadyThere = existing.any(
        (t) => t.recurringRuleId == rule.id && t.isRecurring,
      );
      if (alreadyThere) continue;

      await _transactionRepo.insert(Transaction(
        date: date,
        amountBps: rule.amountBps,
        type: rule.type,
        categoryId: rule.categoryId,
        description: 'Generado automáticamente (recurrente)',
        isRecurring: true,
        recurringRuleId: rule.id,
      ));

      rule.lastGenerated = date;
      await _recurringRepo.update(rule);
      generated++;
    }
    return generated;
  }

  /// The occurrence date for [rule] in the current period, or null if
  /// the activation day hasn't been reached yet.
  DateTime? _occurrenceDate(RecurringRule rule, DateTime now) {
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final day = rule.activationDay > lastDay ? lastDay : rule.activationDay;
    if (now.day < day) return null;

    if (rule.frequency == RecurringFrequency.monthly) {
      return DateTime(now.year, now.month, day);
    }
    // quincenal: activationDay 1 -> day 1, activationDay 16 -> day 16
    return DateTime(now.year, now.month, day);
  }
}
