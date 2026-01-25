import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String groupId;
  final String name;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const StoreModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, Object?> toSqliteMap() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  factory StoreModel.fromSqliteMap(Map<String, Object?> map) {
    return StoreModel(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      name: map['name'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      deletedAt: map['deletedAt'] as int?,
    );
  }

  Map<String, Object?> toFirestoreMap() {
    return {
      'groupId': groupId,
      'name': name,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAt),
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAt),
      'deletedAt':
          deletedAt == null
              ? null
              : Timestamp.fromMillisecondsSinceEpoch(deletedAt!),
    };
  }

  factory StoreModel.fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final deleted = data['deletedAt'] as Timestamp?;
    return StoreModel(
      id: doc.id,
      groupId: data['groupId'] as String,
      name: data['name'] as String,
      createdAt: (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      updatedAt: (data['updatedAt'] as Timestamp).millisecondsSinceEpoch,
      deletedAt: deleted?.millisecondsSinceEpoch,
    );
  }
}
