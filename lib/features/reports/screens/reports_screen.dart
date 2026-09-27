import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/reports_provider.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/income_expense_trend_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                      surface: AppColors.surfaceElevated,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                ref.read(reportsProvider.notifier).setSelectedDate(picked);
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: reportsAsync.when(
          data: (data) => RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceElevated,
            onRefresh: () async {
              await ref.read(reportsProvider.notifier).loadReportsData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeframe Selector Tabs: Daily, Weekly, Monthly, Yearly
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        _buildTimeframeTab(ref, 'Daily', ReportTimeframe.daily, data.timeframe),
                        _buildTimeframeTab(ref, 'Weekly', ReportTimeframe.weekly, data.timeframe),
                        _buildTimeframeTab(ref, 'Monthly', ReportTimeframe.monthly, data.timeframe),
                        _buildTimeframeTab(ref, 'Yearly', ReportTimeframe.yearly, data.timeframe),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Month Carousel Navigation: < September 2026 >
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                          onPressed: () => ref.read(reportsProvider.notifier).previousMonth(),
                        ),
                        Text(
                          DateFormatter.toMonthYear(data.selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                          onPressed: () => ref.read(reportsProvider.notifier).nextMonth(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Income & Expense Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          label: 'Total Income',
                          amount: data.totalIncome,
                          isIncome: true,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMetricCard(
                          label: 'Total Expense',
                          amount: data.totalExpense,
                          isIncome: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Trend Chart
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cashflow Trend',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                _buildLegendIndicator('Income', AppColors.income),
                                const SizedBox(width: 12),
                                _buildLegendIndicator('Expense', AppColors.accentPink),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        IncomeExpenseTrendChart(
                          incomeSpots: data.incomeSpots,
                          expenseSpots: data.expenseSpots,
                          maxY: data.maxY,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Breakdown Donut Chart
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: CategoryDonutChart(
                      items: data.categoryBreakdown,
                      totalExpense: data.totalExpense,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Performance / Closing Balance Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14203D), Color(0xFF0F172C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'This Month',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(data.closingBalance),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Closing Balance',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.income.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.income.withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_upward_rounded, size: 12, color: AppColors.income),
                              SizedBox(width: 3),
                              Text(
                                '+25%\nvs Last Month',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.income,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Text('Error loading reports: $e', style: const TextStyle(color: AppColors.expense)),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeTab(
    WidgetRef ref,
    String label,
    ReportTimeframe timeframe,
    ReportTimeframe activeTimeframe,
  ) {
    final isSelected = timeframe == activeTimeframe;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(reportsProvider.notifier).setTimeframe(timeframe);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    final color = isIncome ? AppColors.income : AppColors.expense;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
                  size: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
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
          const SizedBox(height: 10),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
