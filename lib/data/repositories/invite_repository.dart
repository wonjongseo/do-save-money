import '../models/invite_model.dart';

abstract class InviteRepository {
  /// owner: 이메일로 초대 생성
  Future<InviteModel> createEmailInvite({
    required String groupId,
    required String ownerUid,
    required String inviteeEmail,
    required int expiresAtMillis,
  });

  /// invitee: 초대 문서 1개를 inviteId로 가져오기 (Rules에서 get만 허용)
  Future<InviteModel?> getInviteById({
    required String groupId,
    required String inviteId,
  });

  /// invitee: 초대 수락 (트랜잭션: invite accepted + member 생성)
  Future<void> acceptInvite({
    required String groupId,
    required String inviteId,
    required String uid, // request.auth.uid
    required String displayName, // 멤버 닉네임
  });

  /// owner: 초대 회수
  Future<void> revokeInvite({
    required String groupId,
    required String inviteId,
  });
}
