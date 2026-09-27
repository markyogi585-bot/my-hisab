import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class CashflowSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final bool isVisible;

  const CashflowSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Total Income Card
        Expanded(
          child: _buildItem(
            title: 'Total Income',
            amount: totalIncome,
            isIncome: true,
            icon: Icons.arrow_outward_rounded,
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 14),
        // Total Expense Card
        Expanded(
          child: _buildItem(
            title: 'Total Expense',
            amount: totalExpense,
            isIncome: false,
            icon: Icons.south_west_rounded,
            color: AppColors.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildItem({
    required String title,
    required double amount,
    required bool isIncome,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isVisible ? CurrencyFormatter.format(amount) : '₹ ••••••',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
