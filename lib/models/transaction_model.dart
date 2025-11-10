import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/cart_item_model.dart';

class CustomerDetails {  // model tambahan buat nyimpen detail customer di order list
  final String name;
  final String email;
  final String phone;
  CustomerDetails({required this.name, required this.email, required this.phone});
  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'phone': phone};
}

class TransactionModel {
  final String id;
  final String userId;
  final String eventId;
  final List<CartItemModel> items; 
  final double totalAmount;
  final CustomerDetails customerDetails;
  final String paymentMethodName;
  final String paymentCode; 
  final String status;
  final Timestamp createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.items,
    required this.totalAmount,
    required this.customerDetails,
    required this.paymentMethodName,
    required this.paymentCode,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson(){
    return {
      'userId': userId,
      'eventId': eventId,
      'totalAmount': totalAmount,
      'customerDetails': customerDetails.toJson(),
      'paymentMethodName': paymentMethodName,
      'paymentCode': paymentCode,
      'status': status,
      'createdAt': createdAt,
      'items': items
          .map((item) => {
                'ticketId': item.ticket.id,
                'categoryName': item.ticket.categoryName,
                'quantity': item.quantity.value,
                'price': item.ticket.price,
              })
          .toList(),
    };
  }

  TransactionModel copyWith({     // buat update data transaksi
    String? id,
    String? userId,
    String? eventId,
    List<CartItemModel>? items,
    double? totalAmount,
    CustomerDetails? customerDetails,
    String? paymentMethodName,
    String? paymentCode,
    String? status,
    Timestamp? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      customerDetails: customerDetails ?? this.customerDetails,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      paymentCode: paymentCode ?? this.paymentCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}