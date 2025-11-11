import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/beli_tiket_controller.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'package:tixcycle/models/payment_method_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/repositories/payment_repository.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';

class PembayaranTiketController extends GetxController {
  final PaymentRepository _paymentRepository;
  PembayaranTiketController(this._paymentRepository);
  final UserAccountController _userAccountController = Get.find();

  final EventRepository _eventRepository = Get.find();
  final event = Rx<EventModel?>(null);

  late List<CartItemModel> cartItems;
  late String eventId;

  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  var currentStep = 1.obs;
  var isLoading = false.obs;
  final RxDouble totalPrice = 0.0.obs;

  final RxList<PaymentMethodModel> paymentMethods = <PaymentMethodModel>[].obs;
  final Rx<PaymentMethodModel?> selectedMethod = Rx<PaymentMethodModel?>(null);

  final Rx<TransactionModel?> finalOrder = Rx<TransactionModel?>(null);
  
  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is Map) {
      final Map args = Get.arguments;
      cartItems = args['cartItems'] ?? [];
      eventId = args['eventId'] ?? '';
    } else {
      cartItems = [];
      eventId = '';
    }

    if (cartItems.isEmpty || eventId.isEmpty) {
      Get.back();
      Get.snackbar("Error", "Keranjang kosong atau event tidak valid.");
      return;
    }

    if (eventId.isNotEmpty) {
      _fetchEventDetails(eventId);
    }

    final UserModel? userProfile = _userAccountController.userProfile.value;
    String fullPhoneNumber = userProfile?.phoneNumber ?? '';
    String phoneWithoutPrefix = fullPhoneNumber;
    if (fullPhoneNumber.startsWith('+62')) {
      phoneWithoutPrefix = fullPhoneNumber.substring(3);
    } else if (fullPhoneNumber.startsWith('0')) {
      phoneWithoutPrefix = fullPhoneNumber.substring(1);
    }
    nameController = TextEditingController(
      text: userProfile?.displayName.isNotEmpty ?? false
          ? userProfile!.displayName
          : userProfile?.username ?? '',
    );
    emailController = TextEditingController(
      text: userProfile?.email ?? '',
    );
    phoneController = TextEditingController(text: phoneWithoutPrefix);

    totalPrice.value = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  Future<void> _fetchEventDetails(String eventId) async {
    try {
      final eventData = await _eventRepository.getEventById(eventId);
      event.value = eventData;
    } catch (e) {
      print("Error fetching event details in PaymentController: $e");
    }
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

  void goToStep2() {
    if (formKey.currentState?.validate() ?? false) {
      currentStep.value = 2;
      _fetchPaymentMethods();
    }
  }

  void selectPaymentMethod(PaymentMethodModel method) {
    selectedMethod.value = method;
  }

  void prepareFinalOrder() {
    if (selectedMethod.value == null) {
      Get.snackbar("Error", "Harap pilih metode pembayaran.");
      return;
    }

    final user = _userAccountController.userProfile.value;
    if (user == null) {
      Get.snackbar("Error", "Harap login ulang.");
      return;
    }
    final String formattedPhone = "+62${phoneController.text.trim()}";

    final transaction = _paymentRepository.buildTransactionObject(
      userId: user.id,
      eventId: eventId,
      items: cartItems,
      totalAmount: totalPrice.value,
      customerDetails: CustomerDetails(
        name: nameController.text,
        email: emailController.text,
        phone: formattedPhone,
      ),
      selectedMethod: selectedMethod.value!,
    );

    finalOrder.value = transaction;
    currentStep.value = 3;
  }

  Future<void> saveOrderAndGoToStep4() async {
    if (finalOrder.value == null) {
      Get.snackbar("Error", "Data pesanan tidak ditemukan.");
      return;
    }

    try {
      isLoading(true);

      final savedTransaction =
          await _paymentRepository.saveTransactionToFirebase(finalOrder.value!);
      
      finalOrder.value = savedTransaction;

      currentStep.value = 4;

      if (Get.isRegistered<BeliTiketController>()) {
        final beliTiketController = Get.find<BeliTiketController>();
        beliTiketController.clearCart();
      }
      
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan pesanan: ${e.toString()}");
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