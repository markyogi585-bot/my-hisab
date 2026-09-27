import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_filter.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/filter_provider.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  ConsumerState<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends ConsumerState<TransactionFilterSheet> {
  late FilterType _type;
  String? _categoryId;
  late SortOption _sortOption;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = ref.read(transactionFilterProvider);
    _type = filter.type;
    _categoryId = filter.categoryId;
    _sortOption = filter.sortBy;
    if (filter.minAmount != null) {
      _minController.text = filter.minAmount!.toInt().toString();
    }
    if (filter.maxAmount != null) {
      _maxController.text = filter.maxAmount!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _apply() {
    final min = double.tryParse(_minController.text.trim());
    final max = double.tryParse(_maxController.text.trim());

    ref.read(transactionFilterProvider.notifier).updateFilter(
          TransactionFilter(
            type: _type,
            categoryId: _categoryId,
            minAmount: min,
            maxAmount: max,
            sortBy: _sortOption,
            searchQuery: ref.read(transactionFilterProvider).searchQuery,
          ),
        );
    Navigator.of(context).pop();
  }

  void _reset() {
    ref.read(transactionFilterProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle & Title
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type Filter
            const Text(
              'Transaction Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('All', FilterType.all),
                const SizedBox(width: 8),
                _buildTypeChip('Income', FilterType.income),
                const SizedBox(width: 8),
                _buildTypeChip('Expense', FilterType.expense),
              ],
            ),
            const SizedBox(height: 18),

            // Category Filter
            const Text(
              'Category',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: _categoryId == null,
                  onSelected: (val) {
                    setState(() {
                      _categoryId = null;
                    });
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceCard,
                  labelStyle: TextStyle(
                    color: _categoryId == null ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                ...categories.map((c) {
                  final isSelected = _categoryId == c.id;
                  return ChoiceChip(
                    label: Text(c.name),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _categoryId = val ? c.id : null;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 18),

            // Sort Option
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SortOption.values.map((sort) {
                final isSelected = _sortOption == sort;
                return ChoiceChip(
                  label: Text(sort.displayName),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _sortOption = sort;
                      });
                    }
                  },
                  selectedColor: AppColors.secondary,
                  backgroundColor: AppColors.surfaceCard,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Amount Range
            const Text(
              'Amount Range (₹)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Min Amount',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Max Amount',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, FilterType type) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.6),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
