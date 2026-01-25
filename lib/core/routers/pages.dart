import 'package:do_save_money/feature/auth/login_screen.dart';
import 'package:do_save_money/feature/home/home_screen.dart';
import 'package:do_save_money/feature/splash/controller/splash_controller.dart';
import 'package:do_save_money/feature/splash/screen/splash_screen.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';

class AppPages {
  static List<GetPage> pages = [
    GetPage(
      name: SplashScreen.name,
      page: () => SplashScreen(),
      binding: BindingsBuilder.put(() => SplashController()),
    ),
    GetPage(name: LoginPage.name, page: () => LoginPage()),
    GetPage(name: HomeScreen.name, page: () => HomeScreen()),
  ];
}
