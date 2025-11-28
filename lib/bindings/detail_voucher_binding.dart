import 'package:get/get.dart';
import 'package:tixcycle/controllers/detail_voucher_controller.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';

class DetailVoucherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoucherRepository>(() => VoucherRepository());
    Get.lazyPut<DetailVoucherController>(
      () => DetailVoucherController(Get.find<VoucherRepository>()),
    );
  }
}
