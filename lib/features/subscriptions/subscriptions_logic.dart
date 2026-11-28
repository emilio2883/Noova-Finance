import 'package:decimal/decimal.dart';

import '../../data/models/recurring_rule.dart';

/// Monthly-equivalent charge for a rule (quincenal = 2×/mes).
Decimal subscriptionMonthlyAmount(RecurringRule r) {
  if (r.frequency == RecurringFrequency.monthly) return r.amount;
  return r.amount * Decimal.fromInt(2);
}

/// Sum of monthly charges for ACTIVE subscriptions only.
Decimal subscriptionsMonthlyTotal(List<RecurringRule> rules) {
  var total = Decimal.zero;
  for (final r in rules) {
    if (r.isSubscription && r.isActive) total += subscriptionMonthlyAmount(r);
  }
  return total;
}

/// Annual projection (monthly × 12).
Decimal subscriptionsAnnualTotal(List<RecurringRule> rules) =>
    subscriptionsMonthlyTotal(rules) * Decimal.fromInt(12);
