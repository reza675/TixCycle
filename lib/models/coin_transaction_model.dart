import 'package:cloud_firestore/cloud_firestore.dart';

class CoinTransactionModel {
  final String id;
  final String type; // 'earn' atau 'spend'
  final int amount; // positif untuk earn, negatif untuk spend
  final String description;
  final String? voucherId;
  final DateTime createdAt;

  CoinTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.voucherId,
    required this.createdAt,
  });

  factory CoinTransactionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoinTransactionModel(
      id: doc.id,
      type: data['type'] ?? 'earn',
      amount: data['amount'] ?? 0,
      description: data['description'] ?? '',
      voucherId: data['voucher_id'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
      'voucher_id': voucherId,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
