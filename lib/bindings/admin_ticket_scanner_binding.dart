import 'package:get/get.dart';
import 'package:tixcycle/controllers/admin_ticket_scanner_controller.dart';

class AdminTicketScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminTicketScannerController>(() => AdminTicketScannerController(Get.find()));
  }
}