import 'package:flutter/material.dart';

enum ExportFormat {
  pdf,
  csv,
  txt;

  String get displayName {
    switch (this) {
      case ExportFormat.pdf:
        return 'Export as PDF';
      case ExportFormat.csv:
        return 'Export as CSV';
      case ExportFormat.txt:
        return 'Export as TXT';
    }
  }

  String get description {
    switch (this) {
      case ExportFormat.pdf:
        return 'Generate a detailed PDF report with all transactions, summary and charts.';
      case ExportFormat.csv:
        return 'Export data in CSV format (works with Excel/Google Sheets).';
      case ExportFormat.txt:
        return 'Simple text file with all transactions.';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.txt:
        return 'txt';
    }
  }
}

enum DateRangeOption {
  today,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  thisYear,
  custom;

  String get displayName {
    switch (this) {
      case DateRangeOption.today:
        return 'Today';
      case DateRangeOption.last7Days:
        return 'Last 7 Days';
      case DateRangeOption.last30Days:
        return 'Last 30 Days';
      case DateRangeOption.thisMonth:
        return 'This Month';
      case DateRangeOption.lastMonth:
        return 'Last Month';
      case DateRangeOption.thisYear:
        return 'This Year';
      case DateRangeOption.custom:
        return 'Custom Range';
    }
  }

  DateTimeRange getRange() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (this) {
      case DateRangeOption.today:
        return DateTimeRange(start: todayStart, end: todayEnd);
      case DateRangeOption.last7Days:
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 6)),
          end: todayEnd,
        );
      case DateRangeOption.last30Days:
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 29)),
          end: todayEnd,
        );
      case DateRangeOption.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: todayEnd,
        );
      case DateRangeOption.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: lastMonth, end: lastMonthEnd);
      case DateRangeOption.thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: todayEnd,
        );
      case DateRangeOption.custom:
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 30)),
          end: todayEnd,
        );
    }
  }
}

class ExportConfig {
  final ExportFormat format;
  final DateRangeOption dateRangeOption;
  final DateTimeRange? customRange;

  const ExportConfig({
    this.format = ExportFormat.pdf,
    this.dateRangeOption = DateRangeOption.last30Days,
    this.customRange,
  });

  DateTimeRange get effectiveDateRange {
    if (dateRangeOption == DateRangeOption.custom && customRange != null) {
      return customRange!;
    }
    return dateRangeOption.getRange();
  }

  ExportConfig copyWith({
    ExportFormat? format,
    DateRangeOption? dateRangeOption,
    DateTimeRange? customRange,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      dateRangeOption: dateRangeOption ?? this.dateRangeOption,
      customRange: customRange ?? this.customRange,
    );
  }
}
