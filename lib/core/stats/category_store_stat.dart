/// 기간/마트/카테고리별 평균 가격 통계
class CategoryStoreStat {
  final String groupId;
  final String storeId;
  final String categoryId;
  final int periodStartMillis;
  final int periodEndMillis;
  final int totalPrice;
  final int count;

  const CategoryStoreStat({
    required this.groupId,
    required this.storeId,
    required this.categoryId,
    required this.periodStartMillis,
    required this.periodEndMillis,
    required this.totalPrice,
    required this.count,
  });

  double get averagePrice => count == 0 ? 0 : totalPrice / count;
}
