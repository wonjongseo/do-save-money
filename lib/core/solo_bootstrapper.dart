import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../data/models/group_model.dart';
import '../data/models/member_model.dart';
import '../data/repositories/group_repository.dart';
import '../data/repositories/member_repository.dart';
import 'app_mode.dart';
import 'group_context.dart';
import 'repository_factory.dart';

/// Auth 이전 단계에서 "solo 모드 기본 그룹"을 만들어주는 부트스트래퍼.
/// - 앱 최초 실행 시: 그룹이 없으면 자동 생성
/// - 이미 있으면 첫 그룹을 현재 그룹으로 설정
class SoloBootstrapper {
  final GroupContext _ctx = Get.find<GroupContext>();
  final RepositoryFactory _factory = Get.find<RepositoryFactory>();
  final Uuid _uuid = const Uuid();

  Future<void> ensureSoloGroup() async {
    // solo로 강제 세팅
    _ctx.mode.value = AppMode.solo;

    final GroupRepository groupRepo = _factory.groupRepo();
    final MemberRepository memberRepo = _factory.memberRepo();

    final groups = await groupRepo.getAll();
    if (groups.isNotEmpty) {
      // 이미 그룹이 있으면 첫 그룹을 기본으로 선택
      _ctx.setModeAndGroup(newMode: AppMode.solo, groupId: groups.first.id);
      return;
    }

    // 새 그룹 생성
    final now = DateTime.now().millisecondsSinceEpoch;
    final groupId = _uuid.v4();

    final group = GroupModel(
      id: groupId,
      name: '나의 가계부',
      createdAt: now,
      updatedAt: now,
    );
    await groupRepo.upsert(group);

    // solo에서도 멤버 1명은 넣어두면 purchase.createdByMemberId 추적 구조가 동일해짐
    final memberId = _uuid.v4();
    final me = MemberModel(
      id: memberId,
      groupId: groupId,
      displayName: '나',
      role: 'owner',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
    await memberRepo.upsert(me);

    _ctx.setModeAndGroup(newMode: AppMode.solo, groupId: groupId);
  }
}
