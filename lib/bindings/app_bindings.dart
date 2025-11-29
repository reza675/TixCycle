import 'package:get/get.dart';
import 'package:tixcycle/controllers/location_controller.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/repositories/auth_repository.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:tixcycle/repositories/location_repository.dart';
import 'package:tixcycle/repositories/payment_repository.dart';
import 'package:tixcycle/repositories/ticket_validation_repository.dart';
import 'package:tixcycle/repositories/user_repository.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';
import 'package:tixcycle/services/auth_service.dart';
import 'package:tixcycle/services/firestore_service.dart';
import 'package:tixcycle/services/location_services.dart';
import 'package:tixcycle/controllers/beranda_controller.dart';
import 'package:tixcycle/services/payment_service.dart';
import 'package:tixcycle/services/supabase_storage_service.dart';
import 'package:tixcycle/services/ticket_validation_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // services
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<FirestoreService>(FirestoreService(), permanent: true);
    Get.put<LocationServices>(LocationServices(), permanent: true);
    Get.put<PaymentService>(PaymentService(Get.find()), permanent: true);
    Get.put<TicketValidationService>(TicketValidationService(),
        permanent: true);
    //supabase
    Get.put<SupabaseStorageService>(SupabaseStorageService(), permanent: true);

    // repositories
    Get.put<UserRepository>(UserRepository(Get.find()), permanent: true);
    Get.put<AuthRepository>(AuthRepository(Get.find(), Get.find()),
        permanent: true);
    Get.put<LocationRepository>(LocationRepository(Get.find()),
        permanent: true);
    Get.put<EventRepository>(EventRepository(Get.find()), permanent: true);
    Get.put<PaymentRepository>(PaymentRepository(Get.find(), Get.find()),
        permanent: true);
    Get.put<TicketValidationRepository>(TicketValidationRepository(Get.find()),
        permanent: true);
    Get.put<VoucherRepository>(VoucherRepository(Get.find()), permanent: true);

    // controllers
    Get.put<UserAccountController>(
      UserAccountController(Get.find(), Get.find(), Get.find()),
      permanent: true,
    );
    Get.put<LocationController>(LocationController(Get.find()),
        permanent: true);
    Get.put<BerandaController>(BerandaController(Get.find()), permanent: true);
  }
}
