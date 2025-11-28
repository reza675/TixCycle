import 'package:get/get.dart';
import 'package:tixcycle/models/purchased_ticket_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/repositories/payment_repository.dart';

class TicketDetailController extends GetxController {
  final PaymentRepository _paymentRepository;
  TicketDetailController(this._paymentRepository);

  late PurchasedTicketItem initialData;

  final Rx<PurchasedTicketModel?> ticketLive = Rx<PurchasedTicketModel?>(null);
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is PurchasedTicketItem) {
      initialData = Get.arguments as PurchasedTicketItem;
      _listenToTicketStatus(initialData.ticketId);
    } else {
      Get.back();
      Get.snackbar("Error", "Data tiket tidak valid");
    }
  }

  void _listenToTicketStatus(String ticketId) {
    isLoading(true);
    _paymentRepository.getTicketStream(ticketId).listen(
      (ticketData) {
        ticketLive.value = ticketData;
        isLoading(false);
      },
      onError: (e) {
        print("Error listening to ticket: $e");
        isLoading(false);
      },
    );
  }
}