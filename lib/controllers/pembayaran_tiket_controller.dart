import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'package:tixcycle/models/user_model.dart';

class PembayaranTiketController extends GetxController {
  final List<CartItemModel> cartItems = Get.arguments ?? [];
  final UserAccountController _userAccountController = Get.find();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final UserModel? userProfile = _userAccountController.userProfile.value; 
    nameController = TextEditingController(
      text: userProfile?.displayName.isNotEmpty ?? false
          ? userProfile!.displayName
          : userProfile?.username ?? '',
    );
    emailController = TextEditingController(
      text: userProfile?.email ?? '', 
    );
    phoneController = TextEditingController();

    totalPrice.value =
        cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void lanjutkanPembayaran() {
    // TODO: Implementasikan logika untuk kirim data ke backend/payment gateway
    // 1. Validasi form
    // 2. Kumpulkan data (cartItems, name, email, phone)
    // 3. Buat TransactionModel
    // 4. Kirim data
    // 5. Navigasi ke halaman status pembayaran
    Get.snackbar("Info", "Logika 'Lanjutkan' belum diimplementasikan.");
  }
}