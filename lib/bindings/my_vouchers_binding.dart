import 'package:get/get.dart';
import 'package:tixcycle/controllers/my_vouchers_controller.dart';
import 'package:tixcycle/controllers/my_voucher_detail_controller.dart';

class MyVouchersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyVouchersController>(() => MyVouchersController());
    Get.lazyPut<MyVoucherDetailController>(() => MyVoucherDetailController());
  }
}
