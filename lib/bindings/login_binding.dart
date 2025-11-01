import 'package:get/get.dart';
import 'package:tixcycle/controllers/login_controller.dart';

class LoginBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut(() => LoginController(Get.find()));
  }
}