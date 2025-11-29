import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String name;
  final String description;
  final int priceCoins;
  final int discountAmount;
  final String category;
  final String imageUrl;
  final int stock;
  final String merchantName;
  final List<String> tataCara;
  final DateTime? validUntil;
  final DateTime createdAt;

  VoucherModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCoins,
    required this.discountAmount,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.merchantName,
    required this.tataCara,
    this.validUntil,
    required this.createdAt,
  });

  factory VoucherModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoucherModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      priceCoins: data['price_coins'] ?? 0,
      discountAmount: data['discount_amount'] ?? 0,
      category: data['category'] ?? '',
      imageUrl: data['image_url'] ?? '',
      stock: data['stock'] ?? 0,
      merchantName: data['merchant_name'] ?? '',
      tataCara: (data['tata_cara'] as List<dynamic>?)?.cast<String>() ?? [],
      validUntil: data['valid_until'] != null
          ? (data['valid_until'] as Timestamp).toDate()
          : null,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price_coins': priceCoins,
      'discount_amount': discountAmount,
      'category': category,
      'image_url': imageUrl,
      'stock': stock,
      'merchant_name': merchantName,
      'tata_cara': tataCara,
      'valid_until':
          validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
