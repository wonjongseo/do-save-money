import 'package:do_save_money/core/auth/auth_controller.dart';
import 'package:do_save_money/core/auth/auth_service.dart';
import 'package:do_save_money/core/auth/user_profile_service.dart';
import 'package:do_save_money/data/cloud/repositories/invite_repo_cloud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/group_context.dart';
import '../core/repository_factory.dart';
import '../core/solo_to_shared_migrator.dart';
import '../core/stats/category_stats_service.dart';

import '../data/local/repositories/group_repo_local.dart';
import '../data/local/repositories/member_repo_local.dart';
import '../data/local/repositories/store_repo_local.dart';
import '../data/local/repositories/category_repo_local.dart';
import '../data/local/repositories/purchase_repo_local.dart';

import '../data/cloud/repositories/group_repo_cloud.dart';
import '../data/cloud/repositories/member_repo_cloud.dart';
import '../data/cloud/repositories/store_repo_cloud.dart';
import '../data/cloud/repositories/category_repo_cloud.dart';
import '../data/cloud/repositories/purchase_repo_cloud.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1) 컨텍스트
    Get.put<GroupContext>(GroupContext(), permanent: true);

    // 2) Local Repos
    Get.put<GroupRepoLocal>(GroupRepoLocal(), permanent: true);
    Get.put<MemberRepoLocal>(MemberRepoLocal(), permanent: true);
    Get.put<StoreRepoLocal>(StoreRepoLocal(), permanent: true);
    Get.put<CategoryRepoLocal>(CategoryRepoLocal(), permanent: true);
    Get.put<PurchaseRepoLocal>(PurchaseRepoLocal(), permanent: true);

    // 3) Cloud Repos
    final fs = FirebaseFirestore.instance;
    Get.put<GroupRepoCloud>(GroupRepoCloud(fs), permanent: true);
    Get.put<MemberRepoCloud>(MemberRepoCloud(fs), permanent: true);
    Get.put<StoreRepoCloud>(StoreRepoCloud(fs), permanent: true);
    Get.put<CategoryRepoCloud>(CategoryRepoCloud(fs), permanent: true);
    Get.put<PurchaseRepoCloud>(PurchaseRepoCloud(fs), permanent: true);
    Get.put<InviteRepoCloud>(InviteRepoCloud(fs), permanent: true);
    // 4) Repo Factory
    Get.put<RepositoryFactory>(RepositoryFactory(), permanent: true);
    Get.put<SoloToSharedMigrator>(SoloToSharedMigrator(), permanent: true);
    Get.put<CategoryStatsService>(CategoryStatsService(), permanent: true);

    // -----------------------------
    // ✅ Auth DI
    // // -----------------------------
    // final auth = FirebaseAuth.instance;

    // Get.put<AuthService>(AuthService(auth), permanent: true);
    // Get.put<UserProfileService>(UserProfileService(fs), permanent: true);
    // Get.put<AuthController>(
    //   AuthController(Get.find<AuthService>(), Get.find<UserProfileService>()),
    //   permanent: true,
    // );
  }
}
