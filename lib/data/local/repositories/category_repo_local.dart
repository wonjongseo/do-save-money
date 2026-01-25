import 'package:sqflite/sqflite.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';
import '../local_db.dart';

class CategoryRepoLocal implements CategoryRepository {
  Future<Database> get _db async => LocalDb.database;

  @override
  Future<List<CategoryModel>> getAll(String groupId) async {
    final db = await _db;
    final rows = await db.query(
      'categories',
      where: 'groupId = ? AND deletedAt IS NULL',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((e) => CategoryModel.fromSqliteMap(e)).toList();
  }

  @override
  Future<void> upsert(CategoryModel category) async {
    final db = await _db;
    await db.insert(
      'categories',
      category.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> softDelete(
    String groupId,
    String categoryId,
    int deletedAtMillis,
  ) async {
    final db = await _db;
    await db.update(
      'categories',
      {'deletedAt': deletedAtMillis, 'updatedAt': deletedAtMillis},
      where: 'groupId = ? AND id = ?',
      whereArgs: [groupId, categoryId],
    );
  }
}
