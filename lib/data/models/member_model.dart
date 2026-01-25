import 'package:cloud_firestore/cloud_firestore.dart';

/// 그룹 멤버(Member)
/// - shared 모드에서 핵심
/// - solo 모드에서도 createdBy 추적용으로 1명(나 자신)을 넣어두면 구조가 동일해짐
class MemberModel {
  final String id; // memberId (shared: uid 권장, solo: uuid 가능)
  final String groupId; // 소속 그룹
  final String displayName; // 닉네임
  final String role; // owner | member
  final String status; // active | invited | left
  final int createdAt; // epoch millis
  final int updatedAt; // epoch millis

  const MemberModel({
    required this.id,
    required this.groupId,
    required this.displayName,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  Map<String, Object?> toSqliteMap() {
    return {
      'id': id,
      'groupId': groupId,
      'displayName': displayName,
      'role': role,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory MemberModel.fromSqliteMap(Map<String, Object?> map) {
    return MemberModel(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      displayName: map['displayName'] as String,
      role: map['role'] as String,
      status: map['status'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
    );
  }
  Map<String, Object?> toFirestoreMap() {
    return {
      'groupId': groupId,
      'displayName': displayName,
      'role': role,
      'status': status,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAt),
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAt),
    };
  }

  factory MemberModel.fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MemberModel(
      id: doc.id,
      groupId: data['groupId'] as String,
      displayName: data['displayName'] as String,
      role: data['role'] as String,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      updatedAt: (data['updatedAt'] as Timestamp).millisecondsSinceEpoch,
    );
  }
}
