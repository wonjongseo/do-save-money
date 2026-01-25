import 'package:do_save_money/data/cloud/repositories/category_repo_cloud.dart';
import 'package:do_save_money/data/cloud/repositories/group_repo_cloud.dart';
import 'package:do_save_money/data/cloud/repositories/invite_repo_cloud.dart';
import 'package:do_save_money/data/cloud/repositories/member_repo_cloud.dart';
import 'package:do_save_money/data/cloud/repositories/purchase_repo_cloud.dart';
import 'package:do_save_money/data/cloud/repositories/store_repo_cloud.dart';
import 'package:do_save_money/data/local/repositories/category_repo_local.dart';
import 'package:do_save_money/data/local/repositories/group_repo_local.dart';
import 'package:do_save_money/data/local/repositories/invite_repo_local.dart';
import 'package:do_save_money/data/local/repositories/member_repo_local.dart';
import 'package:do_save_money/data/local/repositories/purchase_repo_local.dart';
import 'package:do_save_money/data/local/repositories/store_repo_local.dart';
import 'package:do_save_money/data/repositories/invite_repository.dart';
import 'package:get/get.dart';
import 'app_mode.dart';
import 'group_context.dart';

import '../data/repositories/group_repository.dart';
import '../data/repositories/member_repository.dart';
import '../data/repositories/store_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/purchase_repository.dart';

/// RepositoryFactory는 "현재 모드"에 따라 적절한 구현체를 제공.
/// - UI/Controller는 Repo 인터페이스만 보고 코딩.
/// - mode 변경 시, 이 팩토리가 반환하는 구현체가 달라짐.
class RepositoryFactory extends GetxService {
  final GroupContext _ctx = Get.find<GroupContext>();

  GroupRepository groupRepo() {
    return _ctx.mode.value == AppMode.solo
        ? Get.find<GroupRepoLocal>()
        : Get.find<GroupRepoCloud>();
  }

  MemberRepository memberRepo() {
    return _ctx.mode.value == AppMode.solo
        ? Get.find<MemberRepoLocal>()
        : Get.find<MemberRepoCloud>();
  }

  StoreRepository storeRepo() {
    return _ctx.mode.value == AppMode.solo
        ? Get.find<StoreRepoLocal>()
        : Get.find<StoreRepoCloud>();
  }

  CategoryRepository categoryRepo() {
    return _ctx.mode.value == AppMode.solo
        ? Get.find<CategoryRepoLocal>()
        : Get.find<CategoryRepoCloud>();
  }

  PurchaseRepository purchaseRepo() {
    return _ctx.mode.value == AppMode.solo
        ? Get.find<PurchaseRepoLocal>()
        : Get.find<PurchaseRepoCloud>();
  }

  InviteRepository inviteRepo() {
    return _ctx.mode.value == AppMode.solo
        ? Get.find<InviteRepoLocal>()
        : Get.find<InviteRepoCloud>();
  }
}
