import 'package:do_save_money/feature/auth/screen/signin_screen.dart';
import 'package:do_save_money/feature/auth/screen/signup_screen.dart';
import 'package:do_save_money/feature/main/screen/main_screen.dart';
import 'package:do_save_money/feature/splash/screen/splash_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static List<GetPage> pages = [
    GetPage(name: SplashScreen.name, page: () => SplashScreen()),
    GetPage(name: SignupScreen.name, page: () => SignupScreen()),
    GetPage(name: SigninScreen.name, page: () => SigninScreen()),
    GetPage(name: MainScreen.name, page: () => MainScreen()),
  ];
}
