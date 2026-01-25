import 'package:sqflite/sqflite.dart';
import '../../models/member_model.dart';
import '../../repositories/member_repository.dart';
import '../local_db.dart';

class MemberRepoLocal implements MemberRepository {
  Future<Database> get _db async => LocalDb.database;

  @override
  Future<MemberModel?> getById(String groupId, String memberId) async {
    final db = await _db;
    final rows = await db.query(
      'members',
      where: 'groupId = ? AND id = ?',
      whereArgs: [groupId, memberId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MemberModel.fromSqliteMap(rows.first);
  }

  @override
  Future<List<MemberModel>> getMembers(String groupId) async {
    final db = await _db;
    final rows = await db.query(
      'members',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt ASC',
    );
    return rows.map((e) => MemberModel.fromSqliteMap(e)).toList();
  }

  @override
  Future<void> upsert(MemberModel member) async {
    final db = await _db;
    await db.insert(
      'members',
      member.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> softDelete(
    String groupId,
    String memberId,
    int deletedAtMillis,
  ) async {
    // members에 deletedAt이 없으므로 status로 처리
    final db = await _db;
    await db.update(
      'members',
      {'status': 'left', 'updatedAt': deletedAtMillis},
      where: 'groupId = ? AND id = ?',
      whereArgs: [groupId, memberId],
    );
  }
}
