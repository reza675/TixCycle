import 'package:get/get_rx/get_rx.dart';
import 'package:tixcycle/models/ticket_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class CartItemModel {
  final TicketModel ticket;
  final RxInt quantity;

  CartItemModel({
    required this.ticket,
    int initialQuantity = 1,
  }) : quantity = initialQuantity.obs;

  void incrementQuantity(){
    quantity.value++;
  }

  void decrementQuantity(){
    if (quantity.value>1) {
      quantity.value--;;
    }
  }

  double get subtotal => ticket.price * quantity.value;
}