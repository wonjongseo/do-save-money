import 'package:do_save_money/core/routers/pages.dart';
import 'package:do_save_money/feature/auth/auth_screen.dart';
import 'package:do_save_money/feature/auth/sign_up_screen.dart';
import 'package:do_save_money/feature/home/home_screen.dart';
import 'package:do_save_money/feature/splash/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bindings/initial_binding.dart';
import 'core/solo_bootstrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // DI 등록
  InitialBinding().dependencies();

  // Auth 이전: solo 기본 group 생성/세팅 (로그인 없이도 동작)
  final bootstrapper = SoloBootstrapper();
  await bootstrapper.ensureSoloGroup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '가게부',
      getPages: AppPages.pages,
      initialRoute: HomeScreen.name,
    );
  }
}

//flutter pub run change_app_package_name:main
