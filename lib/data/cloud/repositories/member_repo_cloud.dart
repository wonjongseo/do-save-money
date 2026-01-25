import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/member_model.dart';
import '../../repositories/member_repository.dart';
import '../firestore_paths.dart';

class MemberRepoCloud implements MemberRepository {
  final FirebaseFirestore _fs;

  MemberRepoCloud(this._fs);

  @override
  Future<MemberModel?> getById(String groupId, String memberId) async {
    final doc =
        await _fs.doc('${FirestorePaths.membersCol(groupId)}/$memberId').get();
    if (!doc.exists) return null;
    return MemberModel.fromFirestoreDoc(doc);
  }

  @override
  Future<List<MemberModel>> getMembers(String groupId) async {
    final qs = await _fs.collection(FirestorePaths.membersCol(groupId)).get();
    return qs.docs.map((d) => MemberModel.fromFirestoreDoc(d)).toList();
  }

  @override
  Future<void> upsert(MemberModel member) async {
    await _fs
        .doc('${FirestorePaths.membersCol(member.groupId)}/${member.id}')
        .set(member.toFirestoreMap(), SetOptions(merge: true));
  }

  @override
  Future<void> softDelete(
    String groupId,
    String memberId,
    int deletedAtMillis,
  ) async {
    // 멤버 삭제는 status를 left로 바꾸는게 일반적
    await _fs.doc('${FirestorePaths.membersCol(groupId)}/$memberId').set({
      'status': 'left',
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(deletedAtMillis),
    }, SetOptions(merge: true));
  }
}
