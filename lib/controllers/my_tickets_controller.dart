import 'package:get/get.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/repositories/payment_repository.dart';

class MyTicketsController extends GetxController {
  final PaymentRepository _paymentRepo = Get.find(); 
  final UserAccountController _userAccountController = Get.find();

  var isLoading = true.obs;

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyTransactions();
  }

  Future<void> fetchMyTransactions() async {
    try {
      isLoading(true);
      final userId = _userAccountController.userProfile.value?.id;
      if (userId == null) {
        throw Exception("Pengguna tidak login.");
      }
      
      final result = await _paymentRepo.getTransactionsForUser(userId);
      transactions.assignAll(result);
      
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat tiket Anda: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }
}