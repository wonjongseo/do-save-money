import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/invite_model.dart';
import '../../models/member_model.dart';
import '../../repositories/invite_repository.dart';
import '../firestore_paths.dart';

class InviteRepoCloud implements InviteRepository {
  final FirebaseFirestore _fs;

  InviteRepoCloud(this._fs);

  @override
  Future<InviteModel> createEmailInvite({
    required String groupId,
    required String ownerUid,
    required String inviteeEmail,
    required int expiresAtMillis,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Firestore 문서 ID 자동 생성
    final docRef = _fs.collection(FirestorePaths.invitesCol(groupId)).doc();

    final invite = InviteModel(
      id: docRef.id,
      groupId: groupId,
      inviteeEmailLower: inviteeEmail.trim().toLowerCase(),
      role: 'member',
      status: 'pending',
      createdByUid: ownerUid,
      createdAt: now,
      expiresAt: expiresAtMillis,
      acceptedByUid: null,
      acceptedAt: null,
    );

    await docRef.set(invite.toFirestoreMap());
    return invite;
  }

  @override
  Future<InviteModel?> getInviteById({
    required String groupId,
    required String inviteId,
  }) async {
    final doc =
        await _fs.doc('${FirestorePaths.invitesCol(groupId)}/$inviteId').get();
    if (!doc.exists) return null;
    return InviteModel.fromFirestoreDoc(doc);
  }

  @override
  Future<void> acceptInvite({
    required String groupId,
    required String inviteId,
    required String uid,
    required String displayName,
  }) async {
    final inviteRef = _fs.doc(
      '${FirestorePaths.invitesCol(groupId)}/$inviteId',
    );
    final memberRef = _fs.doc('${FirestorePaths.membersCol(groupId)}/$uid');

    await _fs.runTransaction((tx) async {
      // 1) invite 읽기
      final inviteSnap = await tx.get(inviteRef);
      if (!inviteSnap.exists) {
        throw StateError('Invite not found');
      }

      final invite = InviteModel.fromFirestoreDoc(inviteSnap);

      // 2) 기본 검증 (Rules에서도 걸러지지만, UX를 위해 클라에서도 체크)
      final now = DateTime.now().millisecondsSinceEpoch;
      if (invite.status != 'pending') {
        throw StateError('Invite is not pending');
      }
      if (invite.expiresAt <= now) {
        throw StateError('Invite expired');
      }

      // 3) 이미 멤버인지 확인(중복 방지)
      final memberSnap = await tx.get(memberRef);
      if (memberSnap.exists) {
        // 이미 멤버면 invite만 accepted 처리하려면 정책 필요
        // MVP에서는 에러로 처리
        throw StateError('Already a member');
      }

      // 4) member 생성
      final member = MemberModel(
        id: uid,
        groupId: groupId,
        displayName: displayName,
        role: 'member',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      // members create 시 Rules에서 inviteId를 요구하도록 해놨으니 포함
      tx.set(memberRef, {...member.toFirestoreMap(), 'inviteId': inviteId});

      // 5) invite accepted 처리
      // Rules에서 acceptedAt == request.time 조건을 썼기 때문에,
      // 서버 시간(request.time)을 정확히 맞추려면 FieldValue.serverTimestamp를 쓰고 싶지만,
      // Rules에서 request.time과 serverTimestamp는 동일 시점으로 평가되므로 아래처럼 처리:
      tx.set(inviteRef, {
        'status': 'accepted',
        'acceptedByUid': uid,
        'acceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> revokeInvite({
    required String groupId,
    required String inviteId,
  }) async {
    final inviteRef = _fs.doc(
      '${FirestorePaths.invitesCol(groupId)}/$inviteId',
    );
    await inviteRef.set({
      'status': 'revoked',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
