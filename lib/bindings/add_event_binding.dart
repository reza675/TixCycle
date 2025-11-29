import 'package:get/get.dart';
import 'package:tixcycle/controllers/add_event_controller.dart';

class AddEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEventController>(
      () => AddEventController(Get.find(), Get.find(),Get.find(),),
    );
  }
}