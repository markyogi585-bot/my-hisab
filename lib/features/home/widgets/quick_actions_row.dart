import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback onReports;
  final VoidCallback onExport;
  final VoidCallback onMore;

  const QuickActionsRow({
    super.key,
    required this.onAddTransaction,
    required this.onReports,
    required this.onExport,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          label: 'Add\nTransaction',
          icon: Icons.add_rounded,
          isPrimary: true,
          onTap: onAddTransaction,
        ),
        _buildActionItem(
          label: 'Reports',
          icon: Icons.bar_chart_rounded,
          onTap: onReports,
        ),
        _buildActionItem(
          label: 'Export',
          icon: Icons.description_outlined,
          onTap: onExport,
        ),
        _buildActionItem(
          label: 'More',
          icon: Icons.grid_view_rounded,
          onTap: onMore,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: isPrimary
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isPrimary ? null : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPrimary
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.border.withOpacity(0.6),
                  width: 1,
                ),
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                color: isPrimary ? Colors.white : AppColors.textSecondary,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
