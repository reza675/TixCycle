import 'package:get/get.dart';
import 'package:tixcycle/models/voucher_model.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';

class DetailVoucherController extends GetxController {
  final VoucherRepository repository;
  DetailVoucherController(this.repository);

  final Rx<VoucherModel?> voucher = Rx<VoucherModel?>(null);
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final VoucherModel? voucherArg = Get.arguments as VoucherModel?;
    if (voucherArg != null) {
      voucher.value = voucherArg;
    }
  }
}
