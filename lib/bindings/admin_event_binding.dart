import 'package:get/get.dart';
import 'package:tixcycle/controllers/admin_event_list_controller.dart';
import 'package:tixcycle/controllers/update_event_controller.dart';

class AdminEventListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminEventListController(Get.find()));
  }
}

class UpdateEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpdateEventController(Get.find(), Get.find()));
  }
}