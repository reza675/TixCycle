import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/models/payment_method_model.dart';
import 'package:tixcycle/services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;
  PaymentRepository(this._service);

  
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
      status: 'pending',
      createdAt: Timestamp.now(),
    );

    return newTransaction;
  }
  Future<TransactionModel> saveTransactionToFirebase(
      TransactionModel transaction) async {
    return _service.createTransaction(transaction);
  }
}