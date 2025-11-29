import 'package:get/get.dart';
import 'package:tixcycle/controllers/merchant_voucher_scanner_controller.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';

class MerchantVoucherScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantVoucherScannerController>(
      () => MerchantVoucherScannerController(Get.find<VoucherRepository>()),
    );
  }
}
