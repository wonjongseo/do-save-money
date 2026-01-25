import 'package:cloud_firestore/cloud_firestore.dart';

/// 그룹(Group)
/// - solo: 로컬 SQLite에 1개 생성될 수도 있음
/// - shared: Firestore groups/{groupId} 문서
class GroupModel {
  final String id; // groupId (UUID or Firestore docId)
  final String name; // 그룹명
  final int createdAt; // epoch millis
  final int updatedAt; // epoch millis
  final String? createdByUid; // shared 생성자(uid) 추적용

  const GroupModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUid,
  });

  // -------------------------
  // SQLite 변환
  // -------------------------
  Map<String, Object?> toSqliteMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory GroupModel.fromSqliteMap(Map<String, Object?> map) {
    return GroupModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: (map['createdAt'] as int),
      updatedAt: (map['updatedAt'] as int),
    );
  }

  // -------------------------
  // Firestore 변환
  // -------------------------
  Map<String, Object?> toFirestoreMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAt),
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAt),
      if (createdByUid != null) 'createdByUid': createdByUid,
    };
  }

  factory GroupModel.fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final createdAtTs = data['createdAt'] as Timestamp;
    final updatedAtTs = data['updatedAt'] as Timestamp;

    return GroupModel(
      id: doc.id,
      name: data['name'] as String,
      createdAt: createdAtTs.millisecondsSinceEpoch,
      updatedAt: updatedAtTs.millisecondsSinceEpoch,
      createdByUid: data['createdByUid'] as String?,
    );
  }

  GroupModel copyWith({String? name, int? updatedAt, String? createdByUid}) {
    return GroupModel(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUid: createdByUid ?? this.createdByUid,
    );
  }
}
