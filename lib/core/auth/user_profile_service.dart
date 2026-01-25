import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_save_money/data/cloud/users_path.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 로그인 성공 시 Firestore users/{uid}에 프로필을 기록해두는 서비스
/// - 초대/멤버 목록/작성자 표시 등에 필요
class UserProfileService {
  final FirebaseFirestore _fs;

  UserProfileService(this._fs);

  Future<void> upsertUserProfile(User user) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _fs.doc(UsersPath.userDoc(user.uid)).set({
      'uid': user.uid,
      'email': user.email, // null일 수도 있음(애플 private relay 등)
      'displayName': user.displayName, // null일 수도 있음
      'photoURL': user.photoURL, // null일 수도 있음
      'lastLoginAt': Timestamp.fromMillisecondsSinceEpoch(now),
      // 최초 생성 시 createdAt이 없으면 채워주기 위해 merge 사용
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
