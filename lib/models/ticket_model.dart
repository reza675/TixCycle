import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String categoryName;
  final double price;
  final String? description;
  final int stock;

  TicketModel({
    required this.id,
    required this.categoryName,
    required this.price,
    this.description = '',
    required this.stock,
  });

  factory TicketModel.fromSnapshot(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      categoryName: data['categoryName'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      stock: (data['stock'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'categoryName' : categoryName,
      'price' : price,
      'description' : description,
      'stock' : stock,
    };
  }
}