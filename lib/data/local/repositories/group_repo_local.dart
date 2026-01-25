import 'package:sqflite/sqflite.dart';
import '../../models/group_model.dart';
import '../../repositories/group_repository.dart';
import '../local_db.dart';

class GroupRepoLocal implements GroupRepository {
  Future<Database> get _db async => LocalDb.database;

  @override
  Future<GroupModel?> getById(String groupId) async {
    final db = await _db;
    final rows = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return GroupModel.fromSqliteMap(rows.first);
  }

  @override
  Future<List<GroupModel>> getAll() async {
    final db = await _db;
    final rows = await db.query('groups', orderBy: 'createdAt DESC');
    return rows.map((e) => GroupModel.fromSqliteMap(e)).toList();
  }

  @override
  Future<void> upsert(GroupModel group) async {
    final db = await _db;
    await db.insert(
      'groups',
      group.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> softDelete(String groupId, int deletedAtMillis) async {
    // v1에서는 groups에 deletedAt 컬럼이 없음.
    // 필요하면 v2에서 컬럼 추가 후 처리.
    // 지금은 "hard delete"로 처리하지 않고 에러를 방지하기 위해 no-op.
  }
}
