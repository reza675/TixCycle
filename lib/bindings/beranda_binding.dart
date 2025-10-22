import 'package:get/get.dart';
import 'package:tixcycle/controllers/beranda_controller.dart';

class BerandaBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut<BerandaController>(()=> BerandaController(Get.find()));
    
  }
}