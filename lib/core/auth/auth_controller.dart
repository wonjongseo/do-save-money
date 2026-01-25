import 'dart:async';

import 'package:do_save_money/core/auth/auth_service.dart';
import 'package:do_save_money/core/auth/user_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final UserProfileService _profileService;

  AuthController(this._authService, this._profileService);

  final Rxn<User> user = Rxn<User>();

  StreamSubscription<User?>? _sub;

  bool get isLoggedIn => user.value != null;
  final RxBool isLoading = false.obs;

  /// 에러 메시지 표시용
  final RxnString errorMessage = RxnString();
  @override
  void onInit() {
    super.onInit();

    user.value = _authService.currentUser;

    _sub = _authService.authStateChanges().listen((u) async {
      user.value = u;

      if (u != null) {
        await _profileService.upsertUserProfile(u);
      }
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> signInGoogle() async {
    final credential = await _authService.signInWithGoogle();
    final u = credential.user;
    if (u != null) {
      await _profileService.upsertUserProfile(u);
    }
  }

  Future<void> signInApple() async {
    final credential = await _authService.signInWithApple();
    final u = credential.user;
    if (u != null) {
      await _profileService.upsertUserProfile(u);
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.signOut();
    } catch (e) {
      errorMessage.value = '로그아웃 실패: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 회원가입
  Future<void> signUp({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      // (선택) 가입 직후 인증메일 발송
      await _authService.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e);
    } catch (e) {
      errorMessage.value = '알 수 없는 오류: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 로그인
  Future<void> signIn({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e);
    } catch (e) {
      errorMessage.value = '알 수 없는 오류: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword({required String email}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.sendPasswordReset(email: email);
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e);
    } catch (e) {
      errorMessage.value = '알 수 없는 오류: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// (선택) 이메일 인증 메일 재발송
  Future<void> resendEmailVerification() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e);
    } catch (e) {
      errorMessage.value = '알 수 없는 오류: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// (선택) 이메일 인증 상태 새로고침
  Future<void> refreshUser() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.reloadUser();
      // reload 후 currentUser를 다시 가져오려면 authStateChanges만으로는 즉시 안 바뀔 수 있으니 수동 갱신
      user.value = FirebaseAuth.instance.currentUser;
    } catch (e) {
      errorMessage.value = '새로고침 실패: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// FirebaseAuthException -> 사용자 친화 메시지 변환
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '존재하지 않는 계정입니다.';
      case 'wrong-password':
        return '비밀번호가 틀렸습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. (최소 6자 이상 권장)';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 활성화되어 있지 않습니다. Firebase 콘솔에서 활성화하세요.';
      case 'too-many-requests':
        return '요청이 너무 많습니다. 잠시 후 다시 시도하세요.';
      default:
        return '인증 오류(${e.code}): ${e.message ?? ''}';
    }
  }
}
