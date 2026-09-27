import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickAmountChips extends StatelessWidget {
  final ValueChanged<double> onAmountAdded;

  const QuickAmountChips({
    super.key,
    required this.onAmountAdded,
  });

  static const List<double> _quickAmounts = [500, 1000, 5000, 10000];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _quickAmounts.map((amount) {
        final label = amount >= 1000
            ? '+${(amount / 1000).toInt()},000'
            : '+$amount';

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAmountAdded(amount),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
