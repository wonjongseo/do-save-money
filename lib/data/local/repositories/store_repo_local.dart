import 'package:sqflite/sqflite.dart';
import '../../models/store_model.dart';
import '../../repositories/store_repository.dart';
import '../local_db.dart';

class StoreRepoLocal implements StoreRepository {
  Future<Database> get _db async => LocalDb.database;

  @override
  Future<List<StoreModel>> getAll(String groupId) async {
    final db = await _db;
    final rows = await db.query(
      'stores',
      where: 'groupId = ? AND deletedAt IS NULL',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((e) => StoreModel.fromSqliteMap(e)).toList();
  }

  @override
  Future<void> upsert(StoreModel store) async {
    final db = await _db;
    await db.insert(
      'stores',
      store.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> softDelete(
    String groupId,
    String storeId,
    int deletedAtMillis,
  ) async {
    final db = await _db;
    await db.update(
      'stores',
      {'deletedAt': deletedAtMillis, 'updatedAt': deletedAtMillis},
      where: 'groupId = ? AND id = ?',
      whereArgs: [groupId, storeId],
    );
  }
}
