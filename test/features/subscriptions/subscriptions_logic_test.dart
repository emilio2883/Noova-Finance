import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/data/models/recurring_rule.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/features/subscriptions/subscriptions_logic.dart';

RecurringRule _r(double amount, RecurringFrequency f,
        {bool sub = true, bool active = true}) =>
    RecurringRule(
      categoryId: 1,
      amountBps: (amount * 10000).round(),
      frequency: f,
      type: TransactionType.expense,
      activationDay: 1,
      startDate: DateTime(2026, 1, 1),
      isSubscription: sub,
      isActive: active,
    );

void main() {
  test('monthly total includes active subscriptions; quincenal counts x2', () {
    final rules = [
      _r(10, RecurringFrequency.monthly), // 10/mo
      _r(5, RecurringFrequency.quincenal), // 10/mo
      _r(99, RecurringFrequency.monthly, active: false), // paused -> excluded
      _r(50, RecurringFrequency.monthly, sub: false), // not a subscription
    ];
    expect(subscriptionsMonthlyTotal(rules), Decimal.parse('20'));
    expect(subscriptionsAnnualTotal(rules), Decimal.parse('240'));
  });

  test('empty list -> zero', () {
    expect(subscriptionsMonthlyTotal(const []), Decimal.zero);
  });
}
