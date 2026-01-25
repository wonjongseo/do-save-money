import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../data/models/group_model.dart';
import '../data/models/member_model.dart';
import '../data/models/purchase_model.dart';
import '../data/local/repositories/group_repo_local.dart';
import '../data/local/repositories/store_repo_local.dart';
import '../data/local/repositories/category_repo_local.dart';
import '../data/local/repositories/purchase_repo_local.dart';
import '../data/cloud/repositories/group_repo_cloud.dart';
import '../data/cloud/repositories/member_repo_cloud.dart';
import '../data/cloud/repositories/store_repo_cloud.dart';
import '../data/cloud/repositories/category_repo_cloud.dart';
import '../data/cloud/repositories/purchase_repo_cloud.dart';
import 'app_mode.dart';
import 'group_context.dart';

/// Solo -> Shared 전환 시 로컬 데이터를 Firestore로 업로드
/// - 그룹/멤버/가게/카테고리/구매내역을 그대로 이관
/// - Solo 멤버ID는 Shared UID로 대체 (createdByMemberId 일괄 변경)
class SoloToSharedMigrator extends GetxService {
  final GroupContext _ctx = Get.find<GroupContext>();

  final GroupRepoLocal _groupLocal = Get.find<GroupRepoLocal>();
  final StoreRepoLocal _storeLocal = Get.find<StoreRepoLocal>();
  final CategoryRepoLocal _categoryLocal = Get.find<CategoryRepoLocal>();
  final PurchaseRepoLocal _purchaseLocal = Get.find<PurchaseRepoLocal>();

  final GroupRepoCloud _groupCloud = Get.find<GroupRepoCloud>();
  final MemberRepoCloud _memberCloud = Get.find<MemberRepoCloud>();
  final StoreRepoCloud _storeCloud = Get.find<StoreRepoCloud>();
  final CategoryRepoCloud _categoryCloud = Get.find<CategoryRepoCloud>();
  final PurchaseRepoCloud _purchaseCloud = Get.find<PurchaseRepoCloud>();

  Future<String> migrateCurrentGroupToShared({
    bool allowOverwrite = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('로그인이 필요합니다.');
    }

    if (_ctx.mode.value != AppMode.solo) {
      throw StateError('현재 모드가 solo가 아닙니다.');
    }

    final groupId = _ctx.currentGroupId.value;
    if (groupId == null || groupId.isEmpty) {
      throw StateError('현재 그룹이 없습니다.');
    }

    final localGroup = await _groupLocal.getById(groupId);
    if (localGroup == null) {
      throw StateError('로컬 그룹을 찾을 수 없습니다.');
    }

    final existing = await _groupCloud.getById(groupId);
    if (existing != null && !allowOverwrite) {
      throw StateError('동일한 groupId가 이미 존재합니다.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final displayName =
        user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : (user.email?.trim().isNotEmpty == true
                ? user.email!.trim()
                : '나');

    // 1) Cloud 그룹 생성/업데이트
    final cloudGroup = GroupModel(
      id: localGroup.id,
      name: localGroup.name,
      createdAt: localGroup.createdAt,
      updatedAt: now,
      createdByUid: user.uid,
    );
    await _groupCloud.upsert(cloudGroup);

    // 2) Owner 멤버 생성 (shared에서는 uid를 memberId로 사용)
    final owner = MemberModel(
      id: user.uid,
      groupId: groupId,
      displayName: displayName,
      role: 'owner',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
    await _memberCloud.upsert(owner);

    // 3) 가게/카테고리 이관
    final stores = await _storeLocal.getAll(groupId);
    for (final store in stores) {
      await _storeCloud.upsert(store);
    }

    final categories = await _categoryLocal.getAll(groupId);
    for (final category in categories) {
      await _categoryCloud.upsert(category);
    }

    // 4) 구매내역 이관 (createdByMemberId를 uid로 치환)
    final farFuture = DateTime(2100, 1, 1).millisecondsSinceEpoch;
    final purchases = await _purchaseLocal.getByDateRange(
      groupId: groupId,
      startMillis: 0,
      endMillis: farFuture,
    );

    for (final p in purchases) {
      final migrated = PurchaseModel(
        id: p.id,
        groupId: p.groupId,
        purchasedAt: p.purchasedAt,
        storeId: p.storeId,
        categoryId: p.categoryId,
        price: p.price,
        createdByMemberId: user.uid, // solo 멤버 -> shared UID
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
        itemName: p.itemName,
        deletedAt: p.deletedAt,
      );
      await _purchaseCloud.upsert(migrated);
    }

    // 5) 모드 전환
    _ctx.setModeAndGroup(newMode: AppMode.shared, groupId: groupId);

    return groupId;
  }
}
