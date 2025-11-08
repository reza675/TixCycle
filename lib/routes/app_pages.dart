import 'package:get/get.dart';
import 'package:tixcycle/bindings/detail_event_binding.dart';
import 'package:tixcycle/bindings/beli_tiket_binding.dart';
import 'package:tixcycle/bindings/login_binding.dart'; 
import 'package:tixcycle/bindings/register_binding.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/views/beli_tiket.dart';
import 'package:tixcycle/views/beranda.dart';
import 'package:tixcycle/views/pencarian_tiket.dart';
import 'package:tixcycle/views/detail_event.dart';
import 'package:tixcycle/views/login_page.dart'; 
import 'package:tixcycle/views/register_page.dart'; 
import 'package:tixcycle/bindings/pembayaran_binding.dart'; 
import 'package:tixcycle/views/pembayaran_tiket.dart';

class AppPages {
  // rute/halaman pertama (nanti diganti splash)
  static const INITIAL = AppRoutes.BERANDA;
  static final routes = [
    GetPage(name: AppRoutes.BERANDA, page: ()=> const BerandaPage()),    // beranda
    GetPage(name: AppRoutes.LIHAT_TIKET, page: ()=> const DetailEventPage(), binding: DetailEventBinding()), // lihat tiket
    GetPage(name: AppRoutes.PENCARIAN_TIKET, page: ()=> const PencarianTiketPage()), // pencarian tiket
    GetPage(name: AppRoutes.BELI_TIKET, page: ()=> const BeliTiket(), binding: BeliTiketBinding()), // beli tiket
    GetPage(name: AppRoutes.LOGIN, page: ()=> const LoginPage(), binding: LoginBinding()), // login page
    GetPage(name: AppRoutes.REGISTER, page: ()=> const RegisterPage(), binding: RegisterBinding()), // register page
    GetPage(name: AppRoutes.CHECKOUT, page: ()=> const PembayaranTiket(), binding: PembayaranBinding()), // pembayaran tiket
  ];
}
