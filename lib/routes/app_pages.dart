import 'package:get/get.dart';
import 'package:tixcycle/bindings/admin_delete_event_binding.dart';
import 'package:tixcycle/bindings/admin_event_binding.dart';
import 'package:tixcycle/bindings/admin_ticket_scanner_binding.dart';
import 'package:tixcycle/bindings/my_tickets_binding.dart';
import 'package:tixcycle/bindings/splash_binding.dart';
import 'package:tixcycle/bindings/ticket_detail_binding.dart';
import 'package:tixcycle/views/admin_delete_event_page.dart';
import 'package:tixcycle/views/admin_event_list_page.dart';
import 'package:tixcycle/views/admin_ticket_scanner_page.dart';
import 'package:tixcycle/views/my_tickets_page.dart';
import 'package:tixcycle/views/splash_screen.dart';
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
import 'package:tixcycle/views/profile_page.dart';
import 'package:tixcycle/bindings/edit_profile_binding.dart';
import 'package:tixcycle/views/edit_profile_page.dart';
import 'package:tixcycle/views/ticket_detail_page.dart';
import 'package:tixcycle/views/admin_manage_events_page.dart';
import 'package:tixcycle/views/update_event_page.dart';
import 'package:tixcycle/views/add_event_page.dart';
import 'package:tixcycle/bindings/add_event_binding.dart';
import 'package:tixcycle/bindings/beranda_binding.dart';
import 'package:tixcycle/bindings/koin_binding.dart';
import 'package:tixcycle/bindings/detail_voucher_binding.dart';
import 'package:tixcycle/bindings/my_vouchers_binding.dart';
import 'package:tixcycle/views/koin_page.dart';
import 'package:tixcycle/views/detail_voucher_page.dart';
import 'package:tixcycle/views/my_vouchers_page.dart';
import 'package:tixcycle/views/my_voucher_detail_page.dart';
import 'package:tixcycle/views/admin_waste_qr_generator_page.dart';
import 'package:tixcycle/views/scan_page.dart';
import 'package:tixcycle/bindings/scan_binding.dart';

class AppPages {
  // rute/halaman pertama (nanti diganti splash)
  static const INITIAL = AppRoutes.SPLASH;
  static final routes = [
    GetPage(
        name: AppRoutes.SPLASH,
        page: () => const SplashScreen(),
        binding: SplashBinding()), // splash screen
    GetPage(
        name: AppRoutes.BERANDA,
        page: () => const BerandaPage(),
        binding: BerandaBinding()), // beranda
    GetPage(
        name: AppRoutes.LIHAT_TIKET,
        page: () => const DetailEventPage(),
        binding: DetailEventBinding()), // lihat tiket
    GetPage(
        name: AppRoutes.PENCARIAN_TIKET,
        page: () => const PencarianTiketPage()), // pencarian tiket
    GetPage(
        name: AppRoutes.BELI_TIKET,
        page: () => const BeliTiket(),
        binding: BeliTiketBinding()), // beli tiket
    GetPage(
        name: AppRoutes.LOGIN,
        page: () => const LoginPage(),
        binding: LoginBinding()), // login page
    GetPage(
        name: AppRoutes.REGISTER,
        page: () => const RegisterPage(),
        binding: RegisterBinding()), // register page
    GetPage(
        name: AppRoutes.CHECKOUT,
        page: () => const PembayaranTiket(),
        binding: PembayaranBinding()), // pembayaran tiket
    GetPage(
        name: AppRoutes.PROFILE,
        page: () => const ProfilePage()), // profile page
    GetPage(
        name: AppRoutes.EDIT_PROFILE,
        page: () => const EditProfilePage(),
        binding: EditProfileBinding()), // edit profile
    GetPage(
      name: AppRoutes.MY_TICKETS,
      page: () => const MyTicketsPage(),
      binding: MyTicketsBinding(),
    ),
    GetPage(
      name: AppRoutes.SCAN,
      page: () => const ScanPage(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_SCANNER,
      page: () => const AdminTicketScannerPage(),
      binding: AdminTicketScannerBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_WASTE_QR,
      page: () => const AdminWasteQRGeneratorPage(),
    ),
    GetPage(
      name: AppRoutes.TICKET_DETAIL,
      page: () => const TicketDetailPage(),
      binding: TicketDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_MANAGE_EVENTS,
      page: () => const AdminManageEventsPage(),
    ),
    GetPage(
      name: AppRoutes.ADD_EVENT,
      page: () => const AddEventPage(),
      binding: AddEventBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_EVENT_LIST,
      page: () => const AdminEventListPage(),
      binding: AdminEventListBinding(),
    ),
    GetPage(
      name: AppRoutes.UPDATE_EVENT,
      page: () => const UpdateEventPage(),
      binding: UpdateEventBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_DELETE_EVENT_LIST,
      page: () => const AdminDeleteEventPage(),
      binding: AdminDeleteEventBinding(),
    ),
    GetPage(
      name: AppRoutes.KOIN,
      page: () => const KoinPage(),
      binding: KoinBinding(),
    ),
    GetPage(
      name: AppRoutes.DETAIL_VOUCHER,
      page: () => const DetailVoucherPage(),
      binding: DetailVoucherBinding(),
    ),
    GetPage(
      name: AppRoutes.MY_VOUCHERS,
      page: () => const MyVouchersPage(),
      binding: MyVouchersBinding(),
    ),
    GetPage(
      name: AppRoutes.MY_VOUCHER_DETAIL,
      page: () => const MyVoucherDetailPage(),
      binding: MyVouchersBinding(),
    ),
  ];
}
