import '../models/purchase_model.dart';

abstract class PurchaseRepository {
  /// 기간 조회: 통계에 그대로 사용
  Future<List<PurchaseModel>> getByDateRange({
    required String groupId,
    required int startMillis,
    required int endMillis,
  });

  Future<void> upsert(PurchaseModel purchase);
  Future<void> softDelete(
    String groupId,
    String purchaseId,
    int deletedAtMillis,
  );
}
