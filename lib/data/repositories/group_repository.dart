import '../models/group_model.dart';

abstract class GroupRepository {
  Future<GroupModel?> getById(String groupId);
  Future<List<GroupModel>> getAll(); // solo에서 의미 있음(shared에서는 제한적으로 사용)
  Future<void> upsert(GroupModel group);
  Future<void> softDelete(String groupId, int deletedAtMillis); // 필요하면 확장
}
