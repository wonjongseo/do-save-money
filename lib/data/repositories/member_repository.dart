import '../models/member_model.dart';

abstract class MemberRepository {
  Future<MemberModel?> getById(String groupId, String memberId);
  Future<List<MemberModel>> getMembers(String groupId);
  Future<void> upsert(MemberModel member);
  Future<void> softDelete(
    String groupId,
    String memberId,
    int deletedAtMillis,
  ); // 필요하면 확장
}
