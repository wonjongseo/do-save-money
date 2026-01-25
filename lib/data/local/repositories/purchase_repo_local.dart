import 'package:sqflite/sqflite.dart';
import '../../models/purchase_model.dart';
import '../../repositories/purchase_repository.dart';
import '../local_db.dart';

class PurchaseRepoLocal implements PurchaseRepository {
  Future<Database> get _db async => LocalDb.database;

  @override
  Future<List<PurchaseModel>> getByDateRange({
    required String groupId,
    required int startMillis,
    required int endMillis,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'purchases',
      where:
          'groupId = ? AND deletedAt IS NULL AND purchasedAt >= ? AND purchasedAt < ?',
      whereArgs: [groupId, startMillis, endMillis],
      orderBy: 'purchasedAt DESC',
    );
    return rows.map((e) => PurchaseModel.fromSqliteMap(e)).toList();
  }

  @override
  Future<void> upsert(PurchaseModel purchase) async {
    final db = await _db;
    await db.insert(
      'purchases',
      purchase.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> softDelete(
    String groupId,
    String purchaseId,
    int deletedAtMillis,
  ) async {
    final db = await _db;
    await db.update(
      'purchases',
      {'deletedAt': deletedAtMillis, 'updatedAt': deletedAtMillis},
      where: 'groupId = ? AND id = ?',
      whereArgs: [groupId, purchaseId],
    );
  }
}
