import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_filter.dart';

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(const TransactionFilter());

  void setType(FilterType type) {
    state = state.copyWith(type: type);
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategory: categoryId == null,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(SortOption sort) {
    state = state.copyWith(sortBy: sort);
  }

  void updateFilter(TransactionFilter newFilter) {
    state = newFilter;
  }

  void reset() {
    state = const TransactionFilter();
  }
}

final transactionFilterProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
  return TransactionFilterNotifier();
});
