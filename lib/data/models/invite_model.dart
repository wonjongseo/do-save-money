import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String id;
  final String groupId;
  final String inviteeEmailLower;
  final String role; // member
  final String status; // pending | accepted | revoked | expired
  final String createdByUid;
  final int createdAt; // epoch millis
  final int expiresAt; // epoch millis
  final String? acceptedByUid;
  final int? acceptedAt;

  const InviteModel({
    required this.id,
    required this.groupId,
    required this.inviteeEmailLower,
    required this.role,
    required this.status,
    required this.createdByUid,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedByUid,
    this.acceptedAt,
  });

  Map<String, Object?> toFirestoreMap() {
    return {
      'groupId': groupId,
      'inviteeEmailLower': inviteeEmailLower,
      'role': role,
      'status': status,
      'createdByUid': createdByUid,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAt),
      'expiresAt': Timestamp.fromMillisecondsSinceEpoch(expiresAt),
      'acceptedByUid': acceptedByUid,
      'acceptedAt':
          acceptedAt == null
              ? null
              : Timestamp.fromMillisecondsSinceEpoch(acceptedAt!),
    };
  }

  factory InviteModel.fromFirestoreDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final createdAtTs = data['createdAt'] as Timestamp;
    final expiresAtTs = data['expiresAt'] as Timestamp;
    final acceptedAtTs = data['acceptedAt'] as Timestamp?;
    return InviteModel(
      id: doc.id,
      groupId: data['groupId'] as String,
      inviteeEmailLower: data['inviteeEmailLower'] as String,
      role: data['role'] as String,
      status: data['status'] as String,
      createdByUid: data['createdByUid'] as String,
      createdAt: createdAtTs.millisecondsSinceEpoch,
      expiresAt: expiresAtTs.millisecondsSinceEpoch,
      acceptedByUid: data['acceptedByUid'] as String?,
      acceptedAt: acceptedAtTs?.millisecondsSinceEpoch,
    );
  }
}
