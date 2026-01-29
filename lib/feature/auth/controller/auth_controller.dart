import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_save_money/core/firebase/paths.dart';
import 'package:do_save_money/feature/auth/screen/signin_screen.dart';
import 'package:do_save_money/feature/main/screen/main_screen.dart';
import 'package:do_save_money/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final _fireAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _fireAuth.authStateChanges();

  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _fireAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw Exception('회원가입 실패');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      UserModel userModel = UserModel(
        uId: user.uid,
        email: user.email ?? email,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(FirebasePaths.users)
          .doc(user.uid)
          .set(userModel.toMap());
      return userModel;
    } catch (e) {
      throw Exception('Failed to Register in: $e');
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _fireAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw Exception('로그인 실패');
      }

      final doc =
          await _firestore.collection(FirebasePaths.users).doc(user.uid).get();
      if (!doc.exists) {
        throw Exception('유저 정보 없음');
      }
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to Sign in: $e');
    }
  }
}

class AuthController extends GetxController {
  final AuthService _authService;
  AuthController(this._authService);

  final _user = Rxn<User>();
  final userModel = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);

    ever(_user, _handleAuthStateChange);
  }

  void _handleAuthStateChange(User? user) {
    if (user == null) {
      if (Get.currentRoute != SigninScreen.name) {
        Get.offAllNamed(SigninScreen.name);
      }
    } else {
      if (Get.currentRoute != MainScreen.name) {
        Get.offAllNamed(MainScreen.name);
      }
    }
  }
}
