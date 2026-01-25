import '../models/store_model.dart';

abstract class StoreRepository {
  Future<List<StoreModel>> getAll(String groupId);
  Future<void> upsert(StoreModel store);
  Future<void> softDelete(String groupId, String storeId, int deletedAtMillis);
}
