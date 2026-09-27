import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/balance_provider.dart';
import '../../../widgets/liquid_glass_card.dart';

class DailyGroupedTransactions extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final ValueChanged<TransactionModel> onTransactionTap;
  final VoidCallback onSeeAll;

  const DailyGroupedTransactions({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
    required this.onSeeAll,
  });

  Map<String, List<TransactionModel>> _groupByDay(List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in list) {
      final txDate = DateTime(tx.dateTime.year, tx.dateTime.month, tx.dateTime.day);
      String groupKey;
      if (txDate == today) {
        groupKey = 'TODAY';
      } else if (txDate == yesterday) {
        groupKey = 'YESTERDAY';
      } else {
        groupKey = DateFormat('EEE, dd MMM yyyy').format(txDate).toUpperCase();
      }

      groups.putIfAbsent(groupKey, () => []).add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return LiquidGlassCard(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Transactions Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your financial ledger is fresh and ready.\nTap "+ Add Entry" above to record your first transaction.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDay(transactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: const Row(
                children: [
                  Text(
                    'Full Ledger',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Grouped Items
        ...grouped.entries.map((entry) {
          final dayLabel = entry.key;
          final dayTxs = entry.value;

          // Calculate daily total
          double dayIncome = 0;
          double dayExpense = 0;
          for (final t in dayTxs) {
            if (t.isIncome) dayIncome += t.amount;
            if (t.isExpense) dayExpense += t.amount;
          }
          final dayNet = dayIncome - dayExpense;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${dayNet >= 0 ? '+' : ''}${CurrencyFormatter.format(dayNet)}',
                      style: TextStyle(
                        color: dayNet >= 0 ? AppColors.income : AppColors.expense,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction items in a Liquid Glass Container
              LiquidGlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dayTxs.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Color(0x14FFFFFF),
                    height: 1,
                  ),
                  itemBuilder: (context, idx) {
                    final tx = dayTxs[idx];
                    return Dismissible(
                      key: Key('home_tx_${tx.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Move to Bin',
                              style: TextStyle(
                                color: AppColors.expense,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 20),
                          ],
                        ),
                      ),
                      onDismissed: (_) async {
                        await ref.read(transactionListProvider.notifier).deleteTransaction(tx.id);
                        await ref.read(balanceProvider.notifier).calculateBalance();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Moved "${tx.title}" to Recycle Bin'),
                              action: SnackBarAction(
                                label: 'RECYCLE BIN',
                                textColor: AppColors.accentCyan,
                                onPressed: () => onSeeAll(),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: InkWell(
                        onTap: () => onTransactionTap(tx),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: tx.isIncome
                                      ? AppColors.income.withOpacity(0.12)
                                      : AppColors.expense.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: tx.isIncome
                                        ? AppColors.income.withOpacity(0.35)
                                        : AppColors.expense.withOpacity(0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  CategoryModel.getIconData(tx.categoryId),
                                  color: tx.isIncome ? AppColors.income : AppColors.expense,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${tx.categoryName} • ${DateFormat('hh:mm a').format(tx.dateTime)}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${tx.isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                                style: TextStyle(
                                  color: tx.isIncome ? AppColors.income : AppColors.expense,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
