import 'package:do_save_money/feature/auth/controller/auth_controller.dart';
import 'package:do_save_money/feature/splash/screen/splash_screen.dart';
import 'package:do_save_money/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '가게부',
      getPages: AppPages.pages,
      initialRoute: SplashScreen.name,
      initialBinding: InitialBinding(),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService());
  }
}

//flutter pub run change_app_package_name:main
