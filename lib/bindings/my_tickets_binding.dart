import 'package:get/get.dart';
import 'package:tixcycle/controllers/my_tickets_controller.dart';

class MyTicketsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyTicketsController>(() => MyTicketsController());
  }
}