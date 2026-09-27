import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'database_provider.dart';
import 'transaction_provider.dart';

enum ReportTimeframe { daily, weekly, monthly, yearly }

class CategoryExpenseItem {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;

  const CategoryExpenseItem({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class ReportsDataState {
  final ReportTimeframe timeframe;
  final DateTime selectedDate;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final double maxY;
  final List<CategoryExpenseItem> categoryBreakdown;
  final double closingBalance;
  final double growthVsLastMonth;

  const ReportsDataState({
    required this.timeframe,
    required this.selectedDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.incomeSpots,
    required this.expenseSpots,
    required this.maxY,
    required this.categoryBreakdown,
    required this.closingBalance,
    required this.growthVsLastMonth,
  });
}

class ReportsNotifier extends StateNotifier<AsyncValue<ReportsDataState>> {
  final Ref _ref;
  ReportTimeframe _currentTimeframe = ReportTimeframe.monthly;
  DateTime _currentDate = DateTime.now();

  ReportsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadReportsData();
  }

  void setTimeframe(ReportTimeframe timeframe) {
    _currentTimeframe = timeframe;
    loadReportsData();
  }

  void previousMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    loadReportsData();
  }

  void nextMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    loadReportsData();
  }

  void setSelectedDate(DateTime date) {
    _currentDate = date;
    loadReportsData();
  }

  Future<void> loadReportsData() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(transactionRepositoryProvider);
      final settings = _ref.read(settingsRepositoryProvider);

      DateTime start;
      DateTime end;

      switch (_currentTimeframe) {
        case ReportTimeframe.daily:
          start = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
          end = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, 23, 59, 59);
          break;
        case ReportTimeframe.weekly:
          final weekday = _currentDate.weekday;
          start = _currentDate.subtract(Duration(days: weekday - 1));
          start = DateTime(start.year, start.month, start.day);
          end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          break;
        case ReportTimeframe.monthly:
          start = DateTime(_currentDate.year, _currentDate.month, 1);
          end = DateTime(_currentDate.year, _currentDate.month + 1, 0, 23, 59, 59);
          break;
        case ReportTimeframe.yearly:
          start = DateTime(_currentDate.year, 1, 1);
          end = DateTime(_currentDate.year, 12, 31, 23, 59, 59);
          break;
      }

      final dateRange = DateTimeRange(start: start, end: end);
      final totals = await repo.getTotals(dateRange: dateRange);
      final totalIncome = totals['income'] ?? 0.0;
      final totalExpense = totals['expense'] ?? 0.0;
      final netBalance = totalIncome - totalExpense;

      // Category breakdown
      final rawCategories = await repo.getCategoryExpenseDistribution(dateRange: dateRange);
      final categoriesList = await repo.getCategoryExpenseDistribution();
      final allCategories = CategoryModel.defaultCategories;

      final List<CategoryExpenseItem> breakdown = [];
      rawCategories.forEach((name, amount) {
        final pct = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;
        final matched = allCategories.firstWhere(
          (c) => c.name.toLowerCase() == name.toLowerCase() || c.id.toLowerCase() == name.toLowerCase(),
          orElse: () => CategoryModel(
            id: name,
            name: name,
            iconKey: 'other',
            colorHex: 0xFF3B82F6,
          ),
        );
        breakdown.add(
          CategoryExpenseItem(
            categoryName: name,
            amount: amount,
            percentage: pct,
            color: matched.color,
          ),
        );
      });

      // Chart points for time series
      final transactions = await repo.getTransactions();
      final filteredTx = transactions.where((t) {
        return t.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.dateTime.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();

      final List<FlSpot> incSpots = [];
      final List<FlSpot> expSpots = [];

      final daysInMonth = end.day;
      final Map<int, double> dailyInc = {};
      final Map<int, double> dailyExp = {};

      for (int i = 1; i <= daysInMonth; i++) {
        dailyInc[i] = 0.0;
        dailyExp[i] = 0.0;
      }

      for (final tx in filteredTx) {
        final day = tx.dateTime.day;
        if (tx.isIncome) {
          dailyInc[day] = (dailyInc[day] ?? 0.0) + tx.amount;
        } else {
          dailyExp[day] = (dailyExp[day] ?? 0.0) + tx.amount;
        }
      }

      double maxAmount = 10000.0;
      for (int i = 1; i <= daysInMonth; i += 2) {
        final incVal = dailyInc[i] ?? 0.0;
        final expVal = dailyExp[i] ?? 0.0;
        incSpots.add(FlSpot(i.toDouble(), incVal));
        expSpots.add(FlSpot(i.toDouble(), expVal));
        if (incVal > maxAmount) maxAmount = incVal;
        if (expVal > maxAmount) maxAmount = expVal;
      }

      final initialBal = settings.initialBalance;
      final closing = initialBal + totalIncome - totalExpense;

      state = AsyncValue.data(
        ReportsDataState(
          timeframe: _currentTimeframe,
          selectedDate: _currentDate,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          netBalance: netBalance,
          incomeSpots: incSpots,
          expenseSpots: expSpots,
          maxY: maxAmount * 1.25,
          categoryBreakdown: breakdown,
          closingBalance: closing,
          growthVsLastMonth: 25.0,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<ReportsDataState>>((ref) {
  ref.watch(transactionListProvider);
  return ReportsNotifier(ref);
});
