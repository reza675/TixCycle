import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'dart:math';

class CustomerDetails {
  final String name;
  final String email;
  final String phone;
  CustomerDetails({required this.name, required this.email, required this.phone});
  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'phone': phone};
}

class PurchasedTicketItem {
  final String ticketId;
  final String categoryName;
  final double price;
  final String seatNumber;

  PurchasedTicketItem({
    required this.ticketId,
    required this.categoryName,
    required this.price,
    required this.seatNumber,
  });

  factory PurchasedTicketItem.fromJson(Map<String, dynamic> json) {
    return PurchasedTicketItem(
      ticketId: json['ticketId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      seatNumber: json['seatNumber'] ?? 'N/A',
    );
  }
}

class TransactionModel {
  final String id;
  final String userId;
  final String eventId;
  final List<CartItemModel> items;
  final List<PurchasedTicketItem> purchasedItems;
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
    this.purchasedItems = const [],
    required this.totalAmount,
    required this.customerDetails,
    required this.paymentMethodName,
    required this.paymentCode,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> itemsForFirestore = [];
    final random = Random();

    for (var cartItem in items) {
      for (int i = 0; i < cartItem.quantity.value; i++) {
        // logika generator aja susah kalau manual di firebase
        String categoryPrefix =
            cartItem.ticket.categoryName.substring(0, 3).toUpperCase();
        String seatLetter =
            String.fromCharCode(65 + random.nextInt(10)); 
        String seatNumber = (random.nextInt(50) + 1).toString(); 
        String generatedSeat = '$categoryPrefix-$seatLetter$seatNumber';

        String generatedTicketId =
            'TKT-${random.nextInt(900)}-${random.nextInt(900)}';

        itemsForFirestore.add({
          'ticketId': generatedTicketId,
          'categoryName': cartItem.ticket.categoryName,
          'price': cartItem.ticket.price,
          'seatNumber': generatedSeat,
          'originalTicketId': cartItem.ticket.id,
        });
      }
    }

    return {
      'userId': userId,
      'eventId': eventId,
      'totalAmount': totalAmount,
      'customerDetails': customerDetails.toJson(),
      'paymentMethodName': paymentMethodName,
      'paymentCode': paymentCode,
      'status': status,
      'createdAt': createdAt,
      'purchasedItems': itemsForFirestore,
    };
  }

  factory TransactionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<PurchasedTicketItem> parsedItems = [];
    if (data['purchasedItems'] != null) {
      for (var item in (data['purchasedItems'] as List)) {
        parsedItems
            .add(PurchasedTicketItem.fromJson(item as Map<String, dynamic>));
      }
    }

    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      items: [],
      purchasedItems: parsedItems,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      customerDetails: CustomerDetails(
        name: data['customerDetails']?['name'] ?? '',
        email: data['customerDetails']?['email'] ?? '',
        phone: data['customerDetails']?['phone'] ?? '',
      ),
      paymentMethodName: data['paymentMethodName'] ?? '',
      paymentCode: data['paymentCode'] ?? '',
      status: data['status'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    List<CartItemModel>? items,
    List<PurchasedTicketItem>? purchasedItems,
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
      purchasedItems: purchasedItems ?? this.purchasedItems,
      totalAmount: totalAmount ?? this.totalAmount,
      customerDetails: customerDetails ?? this.customerDetails,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      paymentCode: paymentCode ?? this.paymentCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}