import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'package:tixcycle/models/ticket_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';

class BeliTiketController extends GetxController {
  final EventRepository _eventRepository;
  BeliTiketController(this._eventRepository);

  var isLoading = false.obs;
  final RxList<TicketModel> availableTickets = <TicketModel>[].obs;
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  RxDouble get totalPrice => RxDouble(
        cartItems.fold(0.0, (sum, item) => sum + item.subtotal),
      );

  @override
  void onInit() {
    super.onInit();
    final String? eventId = Get.parameters['id'];
    if (eventId != null) {
      fetchAvaiableTickets(eventId);
    } else {
      print("Error: Event ID cannot found");
      isLoading(false);
    }
  }

  Future<void> fetchAvaiableTickets(String eventId) async {
    try {
      isLoading(true);
      final tickets = await _eventRepository.getTicketsForEvent(eventId);
      availableTickets.assignAll(tickets);
    } catch (e) {
      print("Error fetching available tickets: $e");
    } finally {
      isLoading(false);
    }
  }

  void addTicketToCart(TicketModel ticket){
    final existingItem = cartItems.firstWhereOrNull((item)=> item.ticket.id == ticket.id);

    int currentQuantity = 0;
    if (existingItem != null) {
      currentQuantity = existingItem.quantity.value;
    }
    if (currentQuantity < ticket.stock) {
      if(existingItem != null){
        existingItem.incrementQuantity();
        cartItems.refresh();
      } else {
        cartItems.add(CartItemModel(ticket: ticket, initialQuantity: 1));
      }
    } else {
      Get.snackbar(
        "Stok Habis", 
        "Maaf, stok untuk tiket ${ticket.categoryName} sudah mencapai batas.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
   }

  void removeTicketFromCart(CartItemModel cartItem) {
    if (cartItem.quantity.value > 1) {
      cartItem.decrementQuantity();
      cartItems.refresh();
    } else {
      cartItems.remove(cartItem);
    }
  }
}
