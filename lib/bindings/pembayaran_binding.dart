import 'package:get/get.dart';
import 'package:tixcycle/controllers/pembayaran_tiket_controller.dart';
class PembayaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PembayaranTiketController>(() => PembayaranTiketController());
  }
}