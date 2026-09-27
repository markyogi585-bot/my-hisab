import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../widgets/category_item_tile.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  CategoryType _activeType = CategoryType.expense;

  static const List<String> _availableIcons = [
    'construction',
    'food',
    'shopping',
    'rent',
    'transport',
    'bills',
    'business',
    'education',
    'health',
    'entertainment',
    'client',
    'salary',
    'investment',
    'other',
  ];

  static const List<int> _availableColors = [
    0xFFEF4444, // Red
    0xFFF59E0B, // Amber
    0xFF10B981, // Green
    0xFF3B82F6, // Blue
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF06B6D4, // Cyan
    0xFF14B8A6, // Teal
    0xFF64748B, // Slate
  ];

  void _showAddEditCategoryDialog({CategoryModel? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedIcon = existing?.iconKey ?? 'other';
    int selectedColor = existing?.colorHex ?? 0xFF3B82F6;
    CategoryType selectedType = existing?.type ?? _activeType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
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
                  Text(
                    existing != null ? 'Edit Category' : 'Add New Category',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  const Text('Category Name', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Groceries, Gym, Freelance',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Icon Picker
                  const Text('Select Icon', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _availableIcons.map((iconKey) {
                        final isSel = selectedIcon == iconKey;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedIcon = iconKey),
                          child: Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.border.withOpacity(0.5),
                              ),
                            ),
                            child: Icon(
                              CategoryModel.getIconData(iconKey),
                              size: 20,
                              color: isSel ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Color Picker
                  const Text('Select Color', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _availableColors.map((colorHex) {
                        final isSel = selectedColor == colorHex;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedColor = colorHex),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Color(colorHex),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        final category = CategoryModel(
                          id: existing?.id ?? const Uuid().v4(),
                          name: name,
                          iconKey: selectedIcon,
                          colorHex: selectedColor,
                          type: selectedType,
                          isDefault: existing?.isDefault ?? false,
                        );

                        if (existing != null) {
                          await ref.read(categoryListProvider.notifier).updateCategory(category);
                        } else {
                          await ref.read(categoryListProvider.notifier).addCategory(category);
                        }

                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        existing != null ? 'Update Category' : 'Create Category',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleDeleteCategory(CategoryModel cat, List<CategoryModel> allCats) async {
    if (cat.transactionCount > 0) {
      // Show migration selection dialog
      final otherCats = allCats.where((c) => c.id != cat.id).toList();
      String? migrateToId = otherCats.isNotEmpty ? otherCats.first.id : null;

      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Reassign Transactions', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cat.name} has ${cat.transactionCount} transactions. Select a category to move them to before deleting:',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                if (otherCats.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: migrateToId,
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: otherCats.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (val) => setDialogState(() => migrateToId = val),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                child: const Text('Migrate & Delete'),
              ),
            ],
          ),
        ),
      );

      if (proceed == true && migrateToId != null) {
        await ref.read(categoryListProvider.notifier).deleteCategory(cat.id, migrateToId: migrateToId);
        await ref.read(transactionListProvider.notifier).loadTransactions();
      }
    } else {
      // Direct deletion confirmation
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete Category', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete "${cat.name}"?',
              style: const TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (proceed == true) {
        await ref.read(categoryListProvider.notifier).deleteCategory(cat.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => _showAddEditCategoryDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          data: (allCategories) {
            final filtered = allCategories.where((c) {
              if (_activeType == CategoryType.expense) {
                return c.type == CategoryType.expense || c.type == CategoryType.both;
              } else {
                return c.type == CategoryType.income || c.type == CategoryType.both;
              }
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Segmented Tabs: Expense vs Income
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Expense', CategoryType.expense),
                        _buildTab('Income', CategoryType.income),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Top Category Grid Preview (including + Add New)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        // + Add New Button Card
                        return GestureDetector(
                          onTap: () => _showAddEditCategoryDialog(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
                                SizedBox(height: 4),
                                Text(
                                  'Add New',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final cat = filtered[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: cat.color.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                CategoryModel.getIconData(cat.iconKey),
                                size: 20,
                                color: cat.color,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Manage Categories Section Header
                  const Text(
                    'Manage Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Manage Categories List
                  ...filtered.map(
                    (cat) => CategoryItemTile(
                      category: cat,
                      onEdit: () => _showAddEditCategoryDialog(existing: cat),
                      onDelete: () => _handleDeleteCategory(cat, allCategories),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Text('Error: $e', style: const TextStyle(color: AppColors.expense)),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, CategoryType type) {
    final isSelected = _activeType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeType = type;
          });
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
