import 'package:get/get.dart';
import 'package:tixcycle/controllers/ticket_detail_controller.dart';

class TicketDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketDetailController>(() => TicketDetailController(Get.find()));
  }
}