import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getAll(String groupId);
  Future<void> upsert(CategoryModel category);
  Future<void> softDelete(
    String groupId,
    String categoryId,
    int deletedAtMillis,
  );
}
