import 'package:get/get.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/repositories/event_repository.dart'; 
import 'package:tixcycle/repositories/payment_repository.dart';

class MyTicketsController extends GetxController {
  
  final PaymentRepository _paymentRepo;
  final EventRepository _eventRepo; 
  final UserAccountController _userAccountController = Get.find();

  
  MyTicketsController(this._paymentRepo, this._eventRepo);

  var isLoading = true.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  final Map<String, EventModel?> _eventCache = {};

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

  
  Future<EventModel?> getEventById(String eventId) async {
    if (_eventCache.containsKey(eventId)) {
      return _eventCache[eventId];
    }

    
    try {
      final event = await _eventRepo.getEventById(eventId);
      _eventCache[eventId] = event; 
      return event;
    } catch (e) {
      print("Error fetching event $eventId: $e");
      _eventCache[eventId] = null; 
      return null;
    }
  }
}