import 'transaction.dart';

const Object _unset = Object();

/// Immutable filter set for advanced transaction search.
class SearchFilters {
  final String text;
  final Set<int> categoryIds; // empty = all
  final TransactionType? type; // null = all
  final DateTime? from;
  final DateTime? to;
  final int? minBps;
  final int? maxBps;
  final bool onlyRecurring;

  const SearchFilters({
    this.text = '',
    this.categoryIds = const <int>{},
    this.type,
    this.from,
    this.to,
    this.minBps,
    this.maxBps,
    this.onlyRecurring = false,
  });

  bool get isEmpty =>
      text.trim().isEmpty &&
      categoryIds.isEmpty &&
      type == null &&
      from == null &&
      to == null &&
      minBps == null &&
      maxBps == null &&
      !onlyRecurring;

  SearchFilters copyWith({
    String? text,
    Set<int>? categoryIds,
    Object? type = _unset,
    Object? from = _unset,
    Object? to = _unset,
    Object? minBps = _unset,
    Object? maxBps = _unset,
    bool? onlyRecurring,
  }) =>
      SearchFilters(
        text: text ?? this.text,
        categoryIds: categoryIds ?? this.categoryIds,
        type: identical(type, _unset) ? this.type : type as TransactionType?,
        from: identical(from, _unset) ? this.from : from as DateTime?,
        to: identical(to, _unset) ? this.to : to as DateTime?,
        minBps: identical(minBps, _unset) ? this.minBps : minBps as int?,
        maxBps: identical(maxBps, _unset) ? this.maxBps : maxBps as int?,
        onlyRecurring: onlyRecurring ?? this.onlyRecurring,
      );
}
