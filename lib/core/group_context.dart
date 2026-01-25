import 'package:get/get.dart';
import 'app_mode.dart';

/// 앱 전체에서 "현재 그룹(groupId)"과 "현재 모드(AppMode)"를 참조해야 함.
/// - solo   : 로컬 DB의 groupId를 사용
/// - shared : Firestore의 groupId(docId)를 사용
class GroupContext extends GetxService {
  /// 현재 모드
  final Rx<AppMode> mode = AppMode.solo.obs;

  /// 현재 그룹 ID (solo/shared 공통으로 동일한 의미)
  final RxnString currentGroupId = RxnString();

  /// 현재 그룹이 세팅되어 있는지
  bool get hasGroup =>
      currentGroupId.value != null && currentGroupId.value!.isNotEmpty;

  /// 현재 모드 + 그룹 변경
  /// - solo 모드에서 신규 그룹 생성 후 set
  /// - shared 모드에서 초대 수락 후 set
  void setModeAndGroup({required AppMode newMode, required String groupId}) {
    mode.value = newMode;
    currentGroupId.value = groupId;
  }

  /// 로그아웃/그룹 나가기 등에서 그룹만 비움
  void clearGroup() {
    currentGroupId.value = null;
  }
}
