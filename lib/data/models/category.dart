import 'package:isar/isar.dart';

import 'transaction.dart';

part 'category.g.dart';

/// Transaction classification. Configurable per spec FR-009.
/// Supports a 2-level hierarchy: principal (isGroup) -> subcategory (parentId).
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

  /// Display order within its level
  int order;

  /// Original Excel row name for import mapping
  @Index()
  String? importKey;

  /// null = top-level (principal group or standalone category).
  /// Otherwise the id of the parent (principal) category.
  @Index()
  int? parentId;

  /// true = principal aggregator category (holds subcategories; may also
  /// receive transactions directly, which roll up into the group total).
  bool isGroup;

  Category({
    required this.name,
    required this.type,
    this.isVariable = false,
    this.isRecurring = false,
    this.isActive = true,
    this.order = 0,
    this.importKey,
    this.parentId,
    this.isGroup = false,
  });
}
