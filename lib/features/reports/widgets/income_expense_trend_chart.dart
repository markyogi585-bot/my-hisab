import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class IncomeExpenseTrendChart extends StatelessWidget {
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final double maxY;

  const IncomeExpenseTrendChart({
    super.key,
    required this.incomeSpots,
    required this.expenseSpots,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (incomeSpots.isEmpty && expenseSpots.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text(
          'No chart data available for this period',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
        ),
      );
    }

    final safeMaxY = maxY <= 0 ? 1000.0 : maxY;

    return AspectRatio(
      aspectRatio: 1.85,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 31,
          minY: 0,
          maxY: safeMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: safeMaxY / 3,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border.withOpacity(0.3),
                strokeWidth: 0.8,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: safeMaxY / 2,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const Text('0', style: TextStyle(color: AppColors.textTertiary, fontSize: 10));
                  }
                  return Text(
                    CurrencyFormatter.formatCompact(value),
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt();
                  if (day == 1 || day == 5 || day == 10 || day == 15 || day == 20 || day == 25 || day == 30) {
                    return Text(
                      '$day',
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.surfaceElevated.withOpacity(0.95),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final isIncome = spot.barIndex == 0;
                  final label = isIncome ? 'Income' : 'Expense';
                  return LineTooltipItem(
                    'Day ${spot.x.toInt()}\n$label: ${CurrencyFormatter.format(spot.y)}',
                    TextStyle(
                      color: isIncome ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Income Line (Cyan/Green neon)
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.income,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.income.withOpacity(0.25),
                    AppColors.income.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Expense Line (Neon Pink/Red)
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.accentPink,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPink.withOpacity(0.25),
                    AppColors.accentPink.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
