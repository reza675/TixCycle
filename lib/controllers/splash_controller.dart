import 'package:get/get.dart';
import 'package:tixcycle/routes/app_routes.dart'; 

class SplashController extends GetxController {

  void goToBeranda() {
    Get.offAllNamed(AppRoutes.BERANDA); 
  }
}