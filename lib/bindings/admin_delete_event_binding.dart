import 'package:get/get.dart';
import 'package:tixcycle/controllers/admin_delete_event_controller.dart';

class AdminDeleteEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminDeleteEventController(Get.find()));
  }
}