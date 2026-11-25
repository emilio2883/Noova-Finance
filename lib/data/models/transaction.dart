import 'package:decimal/decimal.dart';
import 'package:isar/isar.dart';

import '../../core/utils/decimal_utils.dart';

part 'transaction.g.dart';

enum TransactionType { income, expense }

/// A single financial movement.
/// Amount is stored as int in ten-thousandths (BPS-like) to keep exact
/// decimal precision without floating-point (constitution Art. V).
/// e.g. \$107,652.2599 -> amountBps = 1076522599
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  /// Exact transaction date. Quincenas are derived from this, never stored.
  @Index()
  DateTime date;

  /// Amount in ten-thousandths of a unit. Always positive;
  /// sign semantics come from [type].
  int amountBps;

  @Enumerated(EnumType.name)
  TransactionType type;

  /// FK -> Category.id
  int categoryId;

  String? description;

  bool isRecurring;

  /// FK -> RecurringRule.id (null if manual)
  int? recurringRuleId;

  /// Dedup hash for idempotent Excel import: sheet|rowKey|colIndex
  @Index()
  String? importHash;

  DateTime? createdAt;
  DateTime? updatedAt;

  /// Decimal view of [amountBps]. Not stored.
  @ignore
  Decimal get amount => DecimalUtils.fromBps(amountBps);

  Transaction({
    required this.date,
    required this.amountBps,
    required this.type,
    required this.categoryId,
    this.description,
    this.isRecurring = false,
    this.recurringRuleId,
    this.importHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
