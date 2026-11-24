import 'package:decimal/decimal.dart';
import 'package:isar/isar.dart';

import '../../core/utils/decimal_utils.dart';

part 'recurring_rule.g.dart';

enum RecurringFrequency { quincenal, monthly }

/// Rule for auto-generating transactions (spec FR-010).
@collection
class RecurringRule {
  Id id = Isar.autoIncrement;

  /// FK -> Category.id
  int categoryId;

  /// Amount in ten-thousandths of a unit.
  int amountBps;

  @Enumerated(EnumType.name)
  RecurringFrequency frequency;

  /// Day of month when the transaction activates (1-31).
  /// For quincenal: 1 (first quincena) or 16 (second quincena).
  int activationDay;

  bool isActive;

  DateTime startDate;

  /// null = indefinite
  DateTime? endDate;

  /// Last date a transaction was auto-generated for this rule.
  DateTime? lastGenerated;

  /// Decimal view of [amountBps]. Not stored.
  @ignore
  Decimal get amount => DecimalUtils.fromBps(amountBps);

  RecurringRule({
    required this.categoryId,
    required this.amountBps,
    required this.frequency,
    required this.activationDay,
    this.isActive = true,
    required this.startDate,
    this.endDate,
    DateTime? lastGenerated,
  }) : lastGenerated = lastGenerated ?? startDate;
}
