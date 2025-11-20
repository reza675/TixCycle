import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/models/purchased_ticket_model.dart';
import 'package:tixcycle/models/transaction_model.dart';

class ValidationResultModel {
  final PurchasedTicketModel ticket;
  final TransactionModel transaction;
  final EventModel event;

  ValidationResultModel({
    required this.ticket,
    required this.transaction,
    required this.event,
  });
}