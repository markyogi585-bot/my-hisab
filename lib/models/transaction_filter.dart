import 'package:flutter/material.dart';

enum FilterType { all, income, expense }

enum SortOption {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount;

  String get displayName {
    switch (this) {
      case SortOption.newestFirst:
        return 'Newest First';
      case SortOption.oldestFirst:
        return 'Oldest First';
      case SortOption.highestAmount:
        return 'Highest Amount';
      case SortOption.lowestAmount:
        return 'Lowest Amount';
    }
  }
}

class TransactionFilter {
  final FilterType type;
  final String? categoryId;
  final DateTimeRange? dateRange;
  final double? minAmount;
  final double? maxAmount;
  final String searchQuery;
  final SortOption sortBy;

  const TransactionFilter({
    this.type = FilterType.all,
    this.categoryId,
    this.dateRange,
    this.minAmount,
    this.maxAmount,
    this.searchQuery = '',
    this.sortBy = SortOption.newestFirst,
  });

  bool get hasActiveFilters =>
      type != FilterType.all ||
      categoryId != null ||
      dateRange != null ||
      minAmount != null ||
      maxAmount != null ||
      searchQuery.isNotEmpty ||
      sortBy != SortOption.newestFirst;

  TransactionFilter copyWith({
    FilterType? type,
    String? categoryId,
    bool clearCategory = false,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    String? searchQuery,
    SortOption? sortBy,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  TransactionFilter reset() {
    return const TransactionFilter();
  }
}
