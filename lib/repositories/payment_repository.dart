import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/models/payment_method_model.dart';
import 'package:tixcycle/services/firestore_service.dart';
import 'package:tixcycle/services/payment_service.dart';
import 'package:tixcycle/models/purchased_ticket_model.dart';

class PaymentRepository {
  final PaymentService _service;
  final FirestoreService _firestoreService;
  PaymentRepository(this._service, this._firestoreService);

  
  Future<List<PaymentMethodModel>> fetchPaymentMethods() {
    return _service.getPaymentMethods();
  }

 
  TransactionModel buildTransactionObject({
    required String userId,
    required String eventId, 
    required List<CartItemModel> items,
    required double totalAmount,
    required CustomerDetails customerDetails,
    required PaymentMethodModel selectedMethod,
  }) {
    
    String paymentCode;
    if(selectedMethod.category == "Gerai Retail") {
      paymentCode = (Random().nextInt(900000) + 100000).toString(); // 6 digit
    } else {
      paymentCode = "8930" + (Random().nextInt(90000000) + 10000000).toString(); // 12 digit
    }
    

    final newTransaction = TransactionModel(
      id: '', 
      userId: userId,
      eventId: eventId,
      items: items,
      totalAmount: totalAmount,
      customerDetails: customerDetails,
      paymentMethodName: selectedMethod.name,
      paymentCode: paymentCode,
      status: 'completed',
      createdAt: Timestamp.now(),
    );

    return newTransaction;
  }
  Future<TransactionModel> saveTransactionToFirebase(
      TransactionModel transaction) async {
    return _service.createTransaction(transaction);
  }

  Future<List<TransactionModel>> getTransactionsForUser(String userId) async {
    try {
      final querySnapshot = await _firestoreService.getQuery(
        collectionPath: 'transactions', 
        whereField: 'userId',
        isEqualTo: userId,
        orderBy: 'createdAt', 
        descending: true,
      );
      
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print("Error fetching transactions for user $userId: $e");
      rethrow;
    }
  }

  Stream<PurchasedTicketModel> getTicketStream(String ticketId) {
    return _firestoreService
        .getDocumentStream('purchased_tickets/$ticketId') 
        .map((doc) => PurchasedTicketModel.fromSnapshot(doc));
  }
}