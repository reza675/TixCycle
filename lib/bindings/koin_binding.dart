import 'package:get/get.dart';
import 'package:tixcycle/controllers/admin_voucher_controller.dart';
import 'package:tixcycle/controllers/koin_controller.dart';
import 'package:tixcycle/repositories/coin_repository.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';
import 'package:tixcycle/services/supabase_storage_service.dart';

class KoinBinding extends Bindings {
  @override
  void dependencies() {
    // Inject repositories
    Get.lazyPut<CoinRepository>(() => CoinRepository());
    Get.lazyPut<VoucherRepository>(
      () => VoucherRepository(Get.find<SupabaseStorageService>()),
    );

    // Inject controllers
    Get.lazyPut<KoinController>(
      () => KoinController(
        Get.find<CoinRepository>(),
        Get.find<VoucherRepository>(),
      ),
    );

    // Inject AdminVoucherController untuk admin
    Get.lazyPut<AdminVoucherController>(
      () => AdminVoucherController(Get.find<VoucherRepository>()),
    );
  }
}
