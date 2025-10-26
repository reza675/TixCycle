import 'package:get/get.dart';
import 'package:tixcycle/controllers/beli_tiket_controller.dart';

class BeliTiketBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut<BeliTiketController>(()=> BeliTiketController(Get.find()));
  }
}