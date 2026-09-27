import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/balance_provider.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/category_grid_selector.dart';
import '../widgets/datetime_pickers.dart';
import '../widgets/quick_amount_chips.dart';
import '../widgets/type_selector.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? editTransactionId;

  const AddTransactionScreen({
    super.key,
    this.editTransactionId,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDateTime = DateTime.now();
  bool _saveAsTemplate = false;
  bool _isSaving = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    if (widget.editTransactionId != null) {
      _loadTransactionForEdit();
    }
  }

  Future<void> _loadTransactionForEdit() async {
    final txList = ref.read(transactionListProvider).valueOrNull ?? [];
    final match = txList.where((t) => t.id == widget.editTransactionId).firstOrNull;
    if (match != null) {
      setState(() {
        _selectedType = match.type;
        _amountController.text = match.amount.toStringAsFixed(match.amount % 1 == 0 ? 0 : 2);
        _titleController.text = match.title;
        _descriptionController.text = match.description;
        _selectedDateTime = match.dateTime;
        _saveAsTemplate = match.isTemplate;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onAmountAdded(double added) {
    final current = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final total = current + added;
    _amountController.text = total.toStringAsFixed(total % 1 == 0 ? 0 : 2);
    setState(() {
      _amountError = null;
    });
  }

  Future<void> _saveTransaction() async {
    final rawAmount = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Please enter a valid amount greater than 0';
      });
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : _selectedCategory!.name;

    final tx = TransactionModel(
      id: widget.editTransactionId ?? const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      title: title,
      description: _descriptionController.text.trim(),
      dateTime: _selectedDateTime,
      createdAt: now,
      updatedAt: now,
      isTemplate: _saveAsTemplate,
    );

    try {
      if (widget.editTransactionId != null) {
        await ref.read(transactionListProvider.notifier).updateTransaction(tx);
      } else {
        await ref.read(transactionListProvider.notifier).addTransaction(tx);
      }

      await ref.read(balanceProvider.notifier).calculateBalance();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editTransactionId != null
                  ? 'Transaction updated successfully!'
                  : 'Transaction saved successfully!',
            ),
            backgroundColor: AppColors.income,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save transaction: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    // Auto-select first category if not selected or invalid
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    } else if (_selectedCategory != null && !categories.any((c) => c.id == _selectedCategory!.id)) {
      if (categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    }

    final isExpense = _selectedType == TransactionType.expense;
    final isEditing = widget.editTransactionId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Button: Expense (Debit) vs Income (Credit)
                    TypeSelector(
                      selectedType: _selectedType,
                      onTypeChanged: (type) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // Amount Input Field
                    AmountInputField(
                      controller: _amountController,
                      errorText: _amountError,
                      onChanged: (_) {
                        if (_amountError != null) {
                          setState(() {
                            _amountError = null;
                          });
                        }
                      },
                      onClear: () {
                        _amountController.clear();
                        setState(() {
                          _amountError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Quick Amount Chips (+500, +1,000, +5,000, +10,000)
                    QuickAmountChips(
                      onAmountAdded: _onAmountAdded,
                    ),
                    const SizedBox(height: 20),

                    // Category Section Grid
                    CategoryGridSelector(
                      categories: categories,
                      selectedCategoryId: _selectedCategory?.id,
                      onCategorySelected: (cat) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Optional Title
                    const Text(
                      'Title (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withOpacity(0.6)),
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _selectedCategory?.name ?? 'e.g. Construction Material',
                          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Note / Description Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Note / Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_descriptionController.text.length}/200',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withOpacity(0.6)),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        maxLength: 200,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: 'e.g. Cement + Sand payment',
                          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Date & Time Pickers
                    DateTimePickers(
                      selectedDateTime: _selectedDateTime,
                      onDateTimeChanged: (newDt) {
                        setState(() {
                          _selectedDateTime = newDt;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Save as template toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Save as template',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Switch(
                            value: _saveAsTemplate,
                            onChanged: (val) {
                              setState(() {
                                _saveAsTemplate = val;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withOpacity(0.95),
                border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: isExpense
                          ? const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFF8B5CF6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isEditing
                                      ? 'Update Transaction'
                                      : (isExpense ? 'Add Expense' : 'Add Income'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
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
