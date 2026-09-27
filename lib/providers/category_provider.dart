import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import 'database_provider.dart';

class CategoryListNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final Ref _ref;

  CategoryListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories({CategoryType? type}) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      final categories = await repo.getCategories(type: type);
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.addCategory(category);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.updateCategory(category);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCategory(String id, {String? migrateToId}) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(id, migrateToId: migrateToId);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  return CategoryListNotifier(ref);
});

final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final cats = ref.watch(categoryListProvider).valueOrNull ?? [];
  return cats.where((c) => c.type == CategoryType.expense || c.type == CategoryType.both).toList();
});

final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final cats = ref.watch(categoryListProvider).valueOrNull ?? [];
  return cats.where((c) => c.type == CategoryType.income || c.type == CategoryType.both).toList();
});
