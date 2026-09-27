import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/transaction_model.dart';
import 'transaction_tile.dart';

class GroupedTransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final ValueChanged<TransactionModel> onTransactionTap;

  const GroupedTransactionList({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 12),
              Text(
                'No transactions found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Try adjusting your search query or filters.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group transactions by date string
    final Map<String, List<TransactionModel>> groups = {};
    for (final tx in transactions) {
      final key = DateFormatter.toDayMonthYear(tx.dateTime);
      groups.putIfAbsent(key, () => []).add(tx);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.keys.length,
      itemBuilder: (context, index) {
        final dateKey = groups.keys.elementAt(index);
        final dayTxList = groups[dateKey]!;

        // Compute total expense or net for that day
        double dayTotalExpense = 0.0;
        for (final t in dayTxList) {
          if (t.isExpense) {
            dayTotalExpense += t.amount;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header Strip
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (dayTotalExpense > 0)
                    Text(
                      CurrencyFormatter.format(dayTotalExpense),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            // Items for this day
            ...dayTxList.map((tx) => TransactionTile(
                  transaction: tx,
                  onTap: () => onTransactionTap(tx),
                )),
          ],
        );
      },
    );
  }
}
