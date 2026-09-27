import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/transaction_model.dart';

class TypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Expense Button
          Expanded(
            child: _buildButton(
              type: TransactionType.expense,
              label: 'Expense (Debit)',
              icon: Icons.outbox_rounded,
              isSelected: selectedType == TransactionType.expense,
              activeGradient: AppColors.expenseGradient,
              activeShadowColor: AppColors.expense,
            ),
          ),
          const SizedBox(width: 4),
          // Income Button
          Expanded(
            child: _buildButton(
              type: TransactionType.income,
              label: 'Income (Credit)',
              icon: Icons.move_to_inbox_rounded,
              isSelected: selectedType == TransactionType.income,
              activeGradient: AppColors.incomeGradient,
              activeShadowColor: AppColors.income,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required bool isSelected,
    required LinearGradient activeGradient,
    required Color activeShadowColor,
  }) {
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeShadowColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
