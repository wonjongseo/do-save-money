import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/group_model.dart';
import '../../repositories/group_repository.dart';
import '../firestore_paths.dart';

class GroupRepoCloud implements GroupRepository {
  final FirebaseFirestore _fs;

  GroupRepoCloud(this._fs);

  @override
  Future<GroupModel?> getById(String groupId) async {
    final doc = await _fs.doc(FirestorePaths.groupDoc(groupId)).get();
    if (!doc.exists) return null;
    return GroupModel.fromFirestoreDoc(doc);
  }

  @override
  Future<List<GroupModel>> getAll() async {
    // shared 모드에서 "내가 속한 그룹 목록"은 members 기반으로 별도 조회해야 함.
    // 여기서는 단순히 전체 groups를 가져오면 보안상 위험하므로 구현하지 않음.
    // (Auth/Rules 이후에 '내 그룹 목록' 기능으로 확장)
    return [];
  }

  @override
  Future<void> upsert(GroupModel group) async {
    await _fs
        .doc(FirestorePaths.groupDoc(group.id))
        .set(group.toFirestoreMap(), SetOptions(merge: true));
  }

  @override
  Future<void> softDelete(String groupId, int deletedAtMillis) async {
    // shared에서 group 삭제는 owner 권한/초대/멤버 정리 등이 필요하므로
    // Auth/Rules/Functions 설계 후에 구현하는 게 안전함.
  }
}
