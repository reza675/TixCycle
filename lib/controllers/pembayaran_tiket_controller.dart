import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/beli_tiket_controller.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'package:tixcycle/models/payment_method_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/repositories/payment_repository.dart';

class PembayaranTiketController extends GetxController {


  final PaymentRepository _paymentRepository;
  PembayaranTiketController(this._paymentRepository);
  final UserAccountController _userAccountController = Get.find();

  // data dari halaman sebelumnya
  final List<CartItemModel> cartItems = Get.arguments ?? [];
  final String eventId = Get.arguments['eventId'] ??'';

  // form controlller
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // state buat ui
  var currentStep = 1.obs; // 1: Detail, 2: Metode, 3: Bayar
  var isLoading = false.obs;
  final RxDouble totalPrice = 0.0.obs;

  // state tempaat simpan data
  final RxList<PaymentMethodModel> paymentMethods = <PaymentMethodModel>[].obs;
  final Rx<PaymentMethodModel?> selectedMethod = Rx<PaymentMethodModel?>(null);
  final Rx<TransactionModel?> finalOrder = Rx<TransactionModel?>(null);

  @override
  void onInit() {
    super.onInit();

    if (cartItems.isEmpty || eventId.isEmpty) {
        Get.back();
        Get.snackbar("Error", "Keranjang kosong atau event tidak valid.");
        return;
      }

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

  Future<void> _fetchPaymentMethods() async {
    isLoading(true);
    try {
      final methods = await _paymentRepository.fetchPaymentMethods();
      paymentMethods.assignAll(methods);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat metode pembayaran.");
    } finally {
      isLoading(false);
    }
  }

  void goToStep2(){
    if(formKey.currentState?.validate() ?? false){
      currentStep.value =2;
      _fetchPaymentMethods();
    }
  }

  void selectPaymentMethod(PaymentMethodModel method) {
    selectedMethod.value = method;
  }

  Future<void> createFinalOrder() async {
    if (selectedMethod.value == null) {
      Get.snackbar("Error", "Harap pilih metode pembayaran.");
      return;
    }

    try {
      isLoading(true);
      final user = _userAccountController.userProfile.value;
      if (user == null) throw Exception("Harap login ulang.");

      final transaction = await _paymentRepository.createNewTransaction(
        userId: user.id,
        eventId: eventId,
        items: cartItems,
        totalAmount: totalPrice.value,
        customerDetails: CustomerDetails(
          name: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
        ),
        selectedMethod: selectedMethod.value!,
      );

      finalOrder.value = transaction; 
      currentStep.value = 3; 
      
      Get.find<BeliTiketController>().clearCart();

    } catch (e) {
      Get.snackbar("Error", "Gagal membuat pesanan: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

}