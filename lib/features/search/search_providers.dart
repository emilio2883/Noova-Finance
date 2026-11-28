import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/search_filters.dart';

class SearchFiltersNotifier extends StateNotifier<SearchFilters> {
  SearchFiltersNotifier() : super(const SearchFilters());

  void update(SearchFilters f) => state = f;

  void setText(String s) => state = state.copyWith(text: s);

  void setType(Object? type) => state = state.copyWith(type: type);

  void setCategories(Set<int> ids) => state = state.copyWith(categoryIds: ids);

  void setDateRange(DateTime? from, DateTime? to) =>
      state = state.copyWith(from: from, to: to);

  void setAmountRange(int? minBps, int? maxBps) =>
      state = state.copyWith(minBps: minBps, maxBps: maxBps);

  void setOnlyRecurring(bool v) => state = state.copyWith(onlyRecurring: v);

  void reset() => state = const SearchFilters();
}

final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersNotifier, SearchFilters>(
        (ref) => SearchFiltersNotifier());
