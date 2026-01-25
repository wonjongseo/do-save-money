import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // -----------------------------
  // // Google Sign-In
  // // -----------------------------
  Future<UserCredential> signInWithGoogle() async {
    // Google 계정 선택 UI 표시
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // 사용자가 취소한 경우
      throw Exception('Google 로그인 취소');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Firebase credential 생성
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // FirebaseAuth 로그인
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();

    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    return _auth.signInWithCredential(oauthCredential);
  }

  // -----------------------------
  // Sign Out
  // -----------------------------
  Future<void> signOut() async {
    // GoogleSignIn을 쓴 경우 세션도 함께 정리
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // 구글 세션이 없을 수도 있으니 무시
    }
    await _auth.signOut();
  }

  // -----------------------------
  // Nonce helper
  // -----------------------------
  /// 애플 로그인 nonce 생성
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    final result =
        List.generate(
          length,
          (_) => charset[random.nextInt(charset.length)],
        ).join();
    return result;
  }

  /// sha256 해시
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 이메일/비밀번호 회원가입
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// 이메일/비밀번호 로그인
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// 이메일 인증 메일 발송 (선택)
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  /// 이메일 인증 상태 새로고침 (선택)
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reload();
  }
}
