import 'package:cloud_firestore/cloud_firestore.dart';

/// 구매기록(Purchase)
/// - 통계는 categoryId 기준으로 합계(sum(price)) 비교
class PurchaseModel {
  final String id;
  final String groupId;
  final int purchasedAt; // epoch millis
  final String storeId;
  final String categoryId;
  final String? itemName; // 표시용(통계엔 사용 안 함)
  final int price; // 해당 항목 지출 금액
  final String createdByMemberId; // 작성자 추적 (shared에서 중요)
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const PurchaseModel({
    required this.id,
    required this.groupId,
    required this.purchasedAt,
    required this.storeId,
    required this.categoryId,
    required this.price,
    required this.createdByMemberId,
    required this.createdAt,
    required this.updatedAt,
    this.itemName,
    this.deletedAt,
  });

  Map<String, Object?> toSqliteMap() {
    return {
      'id': id,
      'groupId': groupId,
      'purchasedAt': purchasedAt,
      'storeId': storeId,
      'categoryId': categoryId,
      'itemName': itemName,
      'price': price,
      'createdByMemberId': createdByMemberId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  factory PurchaseModel.fromSqliteMap(Map<String, Object?> map) {
    return PurchaseModel(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      purchasedAt: map['purchasedAt'] as int,
      storeId: map['storeId'] as String,
      categoryId: map['categoryId'] as String,
      itemName: map['itemName'] as String?,
      price: map['price'] as int,
      createdByMemberId: map['createdByMemberId'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      deletedAt: map['deletedAt'] as int?,
    );
  }

  Map<String, Object?> toFirestoreMap() {
    return {
      'groupId': groupId,
      'purchasedAt': Timestamp.fromMillisecondsSinceEpoch(purchasedAt),
      'storeId': storeId,
      'categoryId': categoryId,
      'itemName': itemName,
      'price': price,
      'createdByMemberId': createdByMemberId,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAt),
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAt),
      'deletedAt':
          deletedAt == null
              ? null
              : Timestamp.fromMillisecondsSinceEpoch(deletedAt!),
    };
  }

  factory PurchaseModel.fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final deleted = data['deletedAt'] as Timestamp?;
    return PurchaseModel(
      id: doc.id,
      groupId: data['groupId'] as String,
      purchasedAt: (data['purchasedAt'] as Timestamp).millisecondsSinceEpoch,
      storeId: data['storeId'] as String,
      categoryId: data['categoryId'] as String,
      itemName: data['itemName'] as String?,
      price: data['price'] as int,
      createdByMemberId: data['createdByMemberId'] as String,
      createdAt: (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      updatedAt: (data['updatedAt'] as Timestamp).millisecondsSinceEpoch,
      deletedAt: deleted?.millisecondsSinceEpoch,
    );
  }
}
