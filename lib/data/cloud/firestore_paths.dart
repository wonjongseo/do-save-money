/// Firestore 컬렉션 구조(확정):
/// groups/{groupId}
/// groups/{groupId}/members/{memberId}
/// groups/{groupId}/stores/{storeId}
/// groups/{groupId}/categories/{categoryId}
/// groups/{groupId}/purchases/{purchaseId}
/// groups/{groupId}/invites/{inviteId}   (초대 기능은 다음 단계에서 함수/룰까지 붙임)
class FirestorePaths {
  static const String groups = 'groups';

  static String groupDoc(String groupId) => '$groups/$groupId';

  static String membersCol(String groupId) => '${groupDoc(groupId)}/members';
  static String storesCol(String groupId) => '${groupDoc(groupId)}/stores';
  static String categoriesCol(String groupId) =>
      '${groupDoc(groupId)}/categories';
  static String purchasesCol(String groupId) =>
      '${groupDoc(groupId)}/purchases';
  static String invitesCol(String groupId) => '${groupDoc(groupId)}/invites';
}
