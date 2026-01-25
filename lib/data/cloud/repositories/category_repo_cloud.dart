import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';
import '../firestore_paths.dart';

class CategoryRepoCloud implements CategoryRepository {
  final FirebaseFirestore _fs;

  CategoryRepoCloud(this._fs);

  @override
  Future<List<CategoryModel>> getAll(String groupId) async {
    final qs =
        await _fs
            .collection(FirestorePaths.categoriesCol(groupId))
            .where('deletedAt', isNull: true)
            .get();
    return qs.docs.map((d) => CategoryModel.fromFirestoreDoc(d)).toList();
  }

  @override
  Future<void> upsert(CategoryModel category) async {
    await _fs
        .doc('${FirestorePaths.categoriesCol(category.groupId)}/${category.id}')
        .set(category.toFirestoreMap(), SetOptions(merge: true));
  }

  @override
  Future<void> softDelete(
    String groupId,
    String categoryId,
    int deletedAtMillis,
  ) async {
    await _fs.doc('${FirestorePaths.categoriesCol(groupId)}/$categoryId').set({
      'deletedAt': Timestamp.fromMillisecondsSinceEpoch(deletedAtMillis),
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(deletedAtMillis),
    }, SetOptions(merge: true));
  }
}
