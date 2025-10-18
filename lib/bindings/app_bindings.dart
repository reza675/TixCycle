import 'package:get/get.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/repositories/auth_repository.dart';
import 'package:tixcycle/repositories/user_repository.dart';
import 'package:tixcycle/services/auth_service.dart';
import 'package:tixcycle/services/firestore_service.dart';

class AppBindings extends Bindings{
  @override
  void dependencies(){

    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<FirestoreService>(FirestoreService(), permanent: true);
    Get.put<UserRepository>(UserRepository(Get.find()), permanent: true);
    Get.put<AuthRepository>(AuthRepository(Get.find(), Get.find()), permanent: true);

    Get.put<UserAccountController>(
      UserAccountController(Get.find(), Get.find()), permanent: true,);
  }
}