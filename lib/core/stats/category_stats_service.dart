import 'package:get/get.dart';

import '../../data/repositories/purchase_repository.dart';
import '../group_context.dart';
import '../repository_factory.dart';
import 'category_store_stat.dart';
import 'period_utils.dart';
import 'stat_period.dart';

/// 카테고리 평균가 통계 서비스
/// - 통계 단위(일/주/월)는 user가 선택
/// - 평균은 카테고리 내 구매 항목 가격의 평균
class CategoryStatsService extends GetxService {
  final GroupContext _ctx = Get.find<GroupContext>();
  final RepositoryFactory _factory = Get.find<RepositoryFactory>();

  Future<List<CategoryStoreStat>> buildCategoryStoreAverages({
    required int startMillis,
    required int endMillis,
    required StatPeriod period,
    int weekStartsOn = DateTime.monday,
    String? storeId,
    String? categoryId,
  }) async {
    final groupId = _ctx.currentGroupId.value;
    if (groupId == null || groupId.isEmpty) {
      return [];
    }

    final PurchaseRepository repo = _factory.purchaseRepo();
    final purchases = await repo.getByDateRange(
      groupId: groupId,
      startMillis: startMillis,
      endMillis: endMillis,
    );

    final statsMap = <String, _MutableStat>{};

    for (final p in purchases) {
      if (storeId != null && p.storeId != storeId) continue;
      if (categoryId != null && p.categoryId != categoryId) continue;

      final bucketStart = PeriodUtils.floorToPeriodStart(
        millis: p.purchasedAt,
        period: period,
        weekStartsOn: weekStartsOn,
      );
      final bucketEnd = PeriodUtils.nextPeriodStart(
        millis: bucketStart,
        period: period,
        weekStartsOn: weekStartsOn,
      );

      final key = '${p.storeId}::${p.categoryId}::${bucketStart}';
      final stat = statsMap.putIfAbsent(
        key,
        () => _MutableStat(
          groupId: groupId,
          storeId: p.storeId,
          categoryId: p.categoryId,
          periodStartMillis: bucketStart,
          periodEndMillis: bucketEnd,
        ),
      );

      stat.totalPrice += p.price;
      stat.count += 1;
    }

    final list = statsMap.values
        .map(
          (s) => CategoryStoreStat(
            groupId: s.groupId,
            storeId: s.storeId,
            categoryId: s.categoryId,
            periodStartMillis: s.periodStartMillis,
            periodEndMillis: s.periodEndMillis,
            totalPrice: s.totalPrice,
            count: s.count,
          ),
        )
        .toList();

    list.sort((a, b) {
      final c = a.periodStartMillis.compareTo(b.periodStartMillis);
      if (c != 0) return c;
      final s = a.storeId.compareTo(b.storeId);
      if (s != 0) return s;
      return a.categoryId.compareTo(b.categoryId);
    });

    return list;
  }
}

class _MutableStat {
  final String groupId;
  final String storeId;
  final String categoryId;
  final int periodStartMillis;
  final int periodEndMillis;

  int totalPrice = 0;
  int count = 0;

  _MutableStat({
    required this.groupId,
    required this.storeId,
    required this.categoryId,
    required this.periodStartMillis,
    required this.periodEndMillis,
  });
}
