import 'package:do_save_money/feature/home/home_screen.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    Get.offAllNamed(HomeScreen.name);
  }
}
