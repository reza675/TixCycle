import 'package:cloud_firestore/cloud_firestore.dart';
class PurchasedTicketModel {
  final String id; 
  final String transactionId;
  final String eventId;
  final String userId;
  final String categoryName;
  final double price;
  final String seatNumber;
  final bool isCheckedIn;
  final Timestamp? checkInTime;

  PurchasedTicketModel({
    required this.id,
    required this.transactionId,
    required this.eventId,
    required this.userId,
    required this.categoryName,
    required this.price,
    required this.seatNumber,
    this.isCheckedIn = false,
    this.checkInTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'eventId': eventId,
      'userId': userId,
      'categoryName': categoryName,
      'price': price,
      'seatNumber': seatNumber,
      'isCheckedIn': isCheckedIn,
      'checkInTime': checkInTime,
    };
  }
}