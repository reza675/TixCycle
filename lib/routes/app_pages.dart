import 'package:get/get.dart';
import 'package:tixcycle/bindings/beranda_binding.dart';
import 'package:tixcycle/bindings/detail_event_binding.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/views/beranda.dart';
import 'package:tixcycle/views/pencarian_tiket.dart';
import 'package:tixcycle/views/detail_event.dart';
import 'package:tixcycle/views/beli_tiket.dart';

class AppPages {
  // rute/halaman pertama (nanti diganti splash)
  static const INITIAL = AppRoutes.BERANDA;
  static final routes = [
    GetPage(name: AppRoutes.BERANDA, page: ()=> const BerandaPage(), binding: BerandaBinding()),    // beranda
    GetPage(name: AppRoutes.LIHAT_TIKET, page: ()=> const LihatTiketPage(), binding: DetailEventBinding()), // lihat tiket
    GetPage(name: AppRoutes.PENCARIAN_TIKET, page: ()=> const PencarianTiketPage()), // pencarian tiket
    GetPage(name: AppRoutes.BELI_TIKET, page: ()=> const BeliTiket(), binding: DetailEventBinding()), // beli tiket
  ];
}
