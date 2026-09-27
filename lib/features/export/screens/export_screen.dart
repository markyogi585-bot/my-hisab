import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/export_config.dart';
import '../../../models/transaction_filter.dart';
import '../../../providers/balance_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/export_service.dart';
import '../widgets/export_format_card.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  DateRangeOption _dateRangeOption = DateRangeOption.thisMonth;
  DateTimeRange? _customRange;
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final settings = ref.read(settingsRepositoryProvider);

      final config = ExportConfig(
        format: _selectedFormat,
        dateRangeOption: _dateRangeOption,
        customRange: _customRange,
      );

      final range = config.effectiveDateRange;

      // Fetch transactions for this range
      final transactions = await repo.getTransactions(
        filter: TransactionFilter(dateRange: range),
      );

      final totals = await repo.getTotals(dateRange: range);
      final categoryBreakdown = await repo.getCategoryExpenseDistribution(dateRange: range);

      final double totalIncome = totals['income'] ?? 0.0;
      final double totalExpense = totals['expense'] ?? 0.0;
      final double openingBalance = settings.initialBalance;

      if (!mounted) return;

      await ExportService.exportTransactions(
        context: context,
        config: config,
        transactions: transactions,
        openingBalance: openingBalance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        categoryBreakdown: categoryBreakdown,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File ready and shared successfully!'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
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
      setState(() {
        _dateRangeOption = DateRangeOption.custom;
        _customRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Export Data',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Visual Glowing Graphic Header
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Export Your Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose a format to save or share your hisab data.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Export Format Cards
                    ExportFormatCard(
                      format: ExportFormat.pdf,
                      isSelected: _selectedFormat == ExportFormat.pdf,
                      onSelected: () => setState(() => _selectedFormat = ExportFormat.pdf),
                    ),
                    ExportFormatCard(
                      format: ExportFormat.csv,
                      isSelected: _selectedFormat == ExportFormat.csv,
                      onSelected: () => setState(() => _selectedFormat = ExportFormat.csv),
                    ),
                    ExportFormatCard(
                      format: ExportFormat.txt,
                      isSelected: _selectedFormat == ExportFormat.txt,
                      onSelected: () => setState(() => _selectedFormat = ExportFormat.txt),
                    ),
                    const SizedBox(height: 18),

                    // Date Range Selector
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<DateRangeOption>(
                                value: _dateRangeOption,
                                dropdownColor: AppColors.surfaceElevated,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                isExpanded: true,
                                items: DateRangeOption.values.map((option) {
                                  String label = option.displayName;
                                  if (option == DateRangeOption.custom && _customRange != null) {
                                    label =
                                        '${DateFormatter.toDayMonth(_customRange!.start)} - ${DateFormatter.toDayMonth(_customRange!.end)}';
                                  }
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(label),
                                  );
                                }).toList(),
                                onChanged: (opt) {
                                  if (opt == DateRangeOption.custom) {
                                    _pickCustomRange();
                                  } else if (opt != null) {
                                    setState(() {
                                      _dateRangeOption = opt;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withOpacity(0.95),
                border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isExporting ? null : _handleExport,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isExporting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_upload_outlined, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Export Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
