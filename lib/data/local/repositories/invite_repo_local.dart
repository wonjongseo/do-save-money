import '../../models/invite_model.dart';
import '../../repositories/invite_repository.dart';

class InviteRepoLocal implements InviteRepository {
  @override
  Future<InviteModel> createEmailInvite({
    required String groupId,
    required String ownerUid,
    required String inviteeEmail,
    required int expiresAtMillis,
  }) {
    throw UnsupportedError(
      'Invite is only available in shared(Firestore) mode.',
    );
  }

  @override
  Future<InviteModel?> getInviteById({
    required String groupId,
    required String inviteId,
  }) async {
    throw UnsupportedError(
      'Invite is only available in shared(Firestore) mode.',
    );
  }

  @override
  Future<void> acceptInvite({
    required String groupId,
    required String inviteId,
    required String uid,
    required String displayName,
  }) async {
    throw UnsupportedError(
      'Invite is only available in shared(Firestore) mode.',
    );
  }

  @override
  Future<void> revokeInvite({
    required String groupId,
    required String inviteId,
  }) async {
    throw UnsupportedError(
      'Invite is only available in shared(Firestore) mode.',
    );
  }
}
