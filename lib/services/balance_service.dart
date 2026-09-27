import 'package:flutter/material.dart';
import '../core/utils/money.dart';
import '../models/transaction_model.dart';

class BalanceCalculationResult {
  final Money openingBalance;
  final Money totalIncome;
  final Money totalExpense;
  final Money currentBalance;

  const BalanceCalculationResult({
    required this.openingBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.currentBalance,
  });

  double get currentBalanceInRupees => currentBalance.inRupees;
  double get totalIncomeInRupees => totalIncome.inRupees;
  double get totalExpenseInRupees => totalExpense.inRupees;
  double get openingBalanceInRupees => openingBalance.inRupees;
}

class BalanceService {
  const BalanceService();

  /// Calculates authoritative balance strictly from non-deleted ledger transactions.
  /// Formula: currentBalance = openingBalance + totalIncome - totalExpense
  BalanceCalculationResult calculate({
    required Money openingBalance,
    required List<TransactionModel> transactions,
    DateTimeRange? dateRange,
  }) {
    int incomePaise = 0;
    int expensePaise = 0;

    for (final tx in transactions) {
      // Exclude soft-deleted records and templates
      if (tx.isDeleted || tx.isTemplate) continue;

      if (dateRange != null) {
        if (tx.dateTime.isBefore(dateRange.start) || tx.dateTime.isAfter(dateRange.end)) {
          continue;
        }
      }

      if (tx.isIncome) {
        incomePaise += tx.amountMinor;
      } else {
        expensePaise += tx.amountMinor;
      }
    }

    final totalIncome = Money(incomePaise, currency: openingBalance.currency);
    final totalExpense = Money(expensePaise, currency: openingBalance.currency);
    final currentBalance = openingBalance + totalIncome - totalExpense;

    return BalanceCalculationResult(
      openingBalance: openingBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      currentBalance: currentBalance,
    );
  }

  /// Category expense breakdown distribution calculation
  Map<String, Money> calculateCategoryDistribution({
    required List<TransactionModel> transactions,
    DateTimeRange? dateRange,
  }) {
    final Map<String, int> distribution = {};

    for (final tx in transactions) {
      if (tx.isDeleted || tx.isTemplate || !tx.isExpense) continue;

      if (dateRange != null) {
        if (tx.dateTime.isBefore(dateRange.start) || tx.dateTime.isAfter(dateRange.end)) {
          continue;
        }
      }

      final cat = tx.categoryName.isNotEmpty ? tx.categoryName : 'Other';
      distribution[cat] = (distribution[cat] ?? 0) + tx.amountMinor;
    }

    return distribution.map(
      (key, minor) => MapEntry(key, Money(minor)),
    );
  }
}
