import 'package:get/get.dart';
import 'package:tixcycle/models/user_voucher_model.dart';

class MyVoucherDetailController extends GetxController {
  final Rx<UserVoucherModel?> voucher = Rx<UserVoucherModel?>(null);

  @override
  void onInit() {
    super.onInit();
    final UserVoucherModel? voucherArg = Get.arguments as UserVoucherModel?;
    if (voucherArg != null) {
      voucher.value = voucherArg;
    }
  }

  bool get isExpired {
    if (voucher.value == null) return false;
    return voucher.value!.isExpired;
  }

  bool get isUsed => voucher.value?.used ?? false;

  String get statusText {
    if (isUsed) return 'Sudah Digunakan';
    if (isExpired) return 'Sudah Kadaluarsa';
    return 'Belum Digunakan';
  }
}
