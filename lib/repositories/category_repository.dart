import '../data/local/database_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DatabaseService _db;

  CategoryRepository(this._db);

  Future<List<CategoryModel>> getCategories({CategoryType? type}) async {
    return await _db.getAllCategoriesWithCounts(type: type);
  }

  Future<void> addCategory(CategoryModel category) async {
    await _db.insertCategory(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.updateCategory(category);
  }

  Future<void> deleteCategory(String id, {String? migrateToId}) async {
    await _db.deleteCategory(id, migrateToCategoryId: migrateToId);
  }
}
