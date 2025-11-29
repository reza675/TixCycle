import 'package:get/get.dart';
import 'package:tixcycle/controllers/detail_voucher_controller.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';
import 'package:tixcycle/services/supabase_storage_service.dart';

class DetailVoucherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoucherRepository>(
      () => VoucherRepository(Get.find<SupabaseStorageService>()),
    );
    Get.lazyPut<DetailVoucherController>(
      () => DetailVoucherController(Get.find<VoucherRepository>()),
    );
  }
}
