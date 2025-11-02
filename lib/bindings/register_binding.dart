import 'package:get/get.dart';
import 'package:tixcycle/controllers/register_controller.dart';

class RegisterBinding extends Bindings{
  @override
  void dependencies (){
    Get.lazyPut<RegisterController>(()=> RegisterController(Get.find()));
  }
}