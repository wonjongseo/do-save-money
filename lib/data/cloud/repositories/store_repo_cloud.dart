import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/store_model.dart';
import '../../repositories/store_repository.dart';
import '../firestore_paths.dart';

class StoreRepoCloud implements StoreRepository {
  final FirebaseFirestore _fs;

  StoreRepoCloud(this._fs);

  @override
  Future<List<StoreModel>> getAll(String groupId) async {
    final qs =
        await _fs
            .collection(FirestorePaths.storesCol(groupId))
            .where('deletedAt', isNull: true)
            .get();
    return qs.docs.map((d) => StoreModel.fromFirestoreDoc(d)).toList();
  }

  @override
  Future<void> upsert(StoreModel store) async {
    await _fs
        .doc('${FirestorePaths.storesCol(store.groupId)}/${store.id}')
        .set(store.toFirestoreMap(), SetOptions(merge: true));
  }

  @override
  Future<void> softDelete(
    String groupId,
    String storeId,
    int deletedAtMillis,
  ) async {
    await _fs.doc('${FirestorePaths.storesCol(groupId)}/$storeId').set({
      'deletedAt': Timestamp.fromMillisecondsSinceEpoch(deletedAtMillis),
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(deletedAtMillis),
    }, SetOptions(merge: true));
  }
}
