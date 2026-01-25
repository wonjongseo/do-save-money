import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/purchase_model.dart';
import '../../repositories/purchase_repository.dart';
import '../firestore_paths.dart';

class PurchaseRepoCloud implements PurchaseRepository {
  final FirebaseFirestore _fs;

  PurchaseRepoCloud(this._fs);

  @override
  Future<List<PurchaseModel>> getByDateRange({
    required String groupId,
    required int startMillis,
    required int endMillis,
  }) async {
    final startTs = Timestamp.fromMillisecondsSinceEpoch(startMillis);
    final endTs = Timestamp.fromMillisecondsSinceEpoch(endMillis);

    final qs =
        await _fs
            .collection(FirestorePaths.purchasesCol(groupId))
            .where('deletedAt', isNull: true)
            .where('purchasedAt', isGreaterThanOrEqualTo: startTs)
            .where('purchasedAt', isLessThan: endTs)
            .get();

    // 최신순 정렬 (서버 정렬이 필요하면 orderBy를 추가하고 인덱스 설정)
    final list = qs.docs.map((d) => PurchaseModel.fromFirestoreDoc(d)).toList();
    list.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return list;
  }

  @override
  Future<void> upsert(PurchaseModel purchase) async {
    await _fs
        .doc('${FirestorePaths.purchasesCol(purchase.groupId)}/${purchase.id}')
        .set(purchase.toFirestoreMap(), SetOptions(merge: true));
  }

  @override
  Future<void> softDelete(
    String groupId,
    String purchaseId,
    int deletedAtMillis,
  ) async {
    await _fs.doc('${FirestorePaths.purchasesCol(groupId)}/$purchaseId').set({
      'deletedAt': Timestamp.fromMillisecondsSinceEpoch(deletedAtMillis),
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(deletedAtMillis),
    }, SetOptions(merge: true));
  }
}
