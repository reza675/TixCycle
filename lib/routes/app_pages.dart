import 'package:get/get.dart';
import 'package:tixcycle/bindings/detail_event_binding.dart';
import 'package:tixcycle/bindings/beli_tiket_binding.dart'; 
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/views/beli_tiket.dart';
import 'package:tixcycle/views/beranda.dart';
import 'package:tixcycle/views/pencarian_tiket.dart';
import 'package:tixcycle/views/detail_event.dart';

class AppPages {
  // rute/halaman pertama (nanti diganti splash)
  static const INITIAL = AppRoutes.BERANDA;
  static final routes = [
    GetPage(name: AppRoutes.BERANDA, page: ()=> const BerandaPage()),    // beranda
    GetPage(name: AppRoutes.LIHAT_TIKET, page: ()=> const DetailEventPage(), binding: DetailEventBinding()), // lihat tiket
    GetPage(name: AppRoutes.PENCARIAN_TIKET, page: ()=> const PencarianTiketPage()), // pencarian tiket
    GetPage(name: AppRoutes.BELI_TIKET, page: ()=> const BeliTiket(), binding: BeliTiketBinding()), // beli tiket
  ];
}
