import 'package:decimal/decimal.dart';
import 'package:isar/isar.dart';

import '../../core/utils/decimal_utils.dart';

part 'budget.g.dart';

/// Spending limit for a variable expense category (spec FR-015..FR-017).
@collection
class Budget {
  Id id = Isar.autoIncrement;

  /// FK -> Category.id (variable categories only)
  int categoryId;

  /// Budget per quincena in ten-thousandths of a unit.
  int amountPerQuincenaBps;

  /// Alert threshold percentage (default 80)
  int alertThreshold;

  bool isActive;

  DateTime? createdAt;
  DateTime? updatedAt;

  /// Decimal view of [amountPerQuincenaBps]. Not stored.
  @ignore
  Decimal get amountPerQuincena => DecimalUtils.fromBps(amountPerQuincenaBps);

  Budget({
    required this.categoryId,
    required this.amountPerQuincenaBps,
    this.alertThreshold = 80,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
