import 'package:isar/isar.dart';

import 'transaction.dart';

part 'category.g.dart';

/// Transaction classification. Configurable per spec FR-009.
@collection
class Category {
  Id id = Isar.autoIncrement;

  String name;

  @Enumerated(EnumType.name)
  TransactionType type;

  /// true = variable expense, eligible for budgets (spec FR-015)
  bool isVariable;

  /// true = typically recurring (has or had a RecurringRule)
  bool isRecurring;

  /// false = hidden from selector; past transactions remain visible
  bool isActive;

  /// Display order in selector and reports
  int order;

  /// Original Excel row name for import mapping
  @Index()
  String? importKey;

  Category({
    required this.name,
    required this.type,
    this.isVariable = false,
    this.isRecurring = false,
    this.isActive = true,
    this.order = 0,
    this.importKey,
  });
}
