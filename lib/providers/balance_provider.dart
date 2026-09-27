import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import 'transaction_provider.dart';

class BalanceState {
  final double currentBalance;
  final double initialBalance;
  final double totalIncome;
  final double totalExpense;
  final double monthIncome;
  final double monthExpense;
  final double monthGrowthPercent;
  final bool isVisible;

  const BalanceState({
    required this.currentBalance,
    required this.initialBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthIncome,
    required this.monthExpense,
    required this.monthGrowthPercent,
    required this.isVisible,
  });

  BalanceState copyWith({
    double? currentBalance,
    double? initialBalance,
    double? totalIncome,
    double? totalExpense,
    double? monthIncome,
    double? monthExpense,
    double? monthGrowthPercent,
    bool? isVisible,
  }) {
    return BalanceState(
      currentBalance: currentBalance ?? this.currentBalance,
      initialBalance: initialBalance ?? this.initialBalance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      monthIncome: monthIncome ?? this.monthIncome,
      monthExpense: monthExpense ?? this.monthExpense,
      monthGrowthPercent: monthGrowthPercent ?? this.monthGrowthPercent,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class BalanceNotifier extends StateNotifier<AsyncValue<BalanceState>> {
  final Ref _ref;

  BalanceNotifier(this._ref) : super(const AsyncValue.loading()) {
    calculateBalance();
  }

  Future<void> calculateBalance() async {
    try {
      final settings = _ref.read(settingsRepositoryProvider);
      final repo = _ref.read(transactionRepositoryProvider);

      final initialBal = settings.initialBalance;
      final isVisible = settings.isBalanceVisible;

      // All time totals
      final allTimeTotals = await repo.getTotals();
      final totalInc = allTimeTotals['income'] ?? 0.0;
      final totalExp = allTimeTotals['expense'] ?? 0.0;
      final calculatedBalance = initialBal + totalInc - totalExp;

      // Current month range
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);
      final currentMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final monthTotals = await repo.getTotals(
        dateRange: DateTimeRange(start: currentMonthStart, end: currentMonthEnd),
      );
      final monthInc = monthTotals['income'] ?? 0.0;
      final monthExp = monthTotals['expense'] ?? 0.0;

      // Last month range for growth calculation
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
      final lastMonthTotals = await repo.getTotals(
        dateRange: DateTimeRange(start: lastMonthStart, end: lastMonthEnd),
      );
      final lastMonthNet = (lastMonthTotals['income'] ?? 0.0) - (lastMonthTotals['expense'] ?? 0.0);
      final currentMonthNet = monthInc - monthExp;

      double growth = 12.5; // Baseline fallback
      if (lastMonthNet > 0) {
        growth = ((currentMonthNet - lastMonthNet) / lastMonthNet) * 100;
      }

      state = AsyncValue.data(
        BalanceState(
          currentBalance: calculatedBalance,
          initialBalance: initialBal,
          totalIncome: monthInc > 0 ? monthInc : totalInc,
          totalExpense: monthExp > 0 ? monthExp : totalExp,
          monthIncome: monthInc,
          monthExpense: monthExp,
          monthGrowthPercent: growth,
          isVisible: isVisible,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleVisibility() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final newVisibility = !current.isVisible;
    await _ref.read(settingsRepositoryProvider).setBalanceVisible(newVisibility);
    state = AsyncValue.data(current.copyWith(isVisible: newVisibility));
  }

  Future<void> updateInitialBalance(double balance) async {
    await _ref.read(settingsRepositoryProvider).setInitialBalance(balance);
    await calculateBalance();
  }
}

final balanceProvider =
    StateNotifierProvider<BalanceNotifier, AsyncValue<BalanceState>>((ref) {
  // Re-calculate whenever transactions change
  ref.watch(transactionListProvider);
  return BalanceNotifier(ref);
});
