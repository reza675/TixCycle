import 'package:cloud_firestore/cloud_firestore.dart';


class WasteTypeModel {
  final String id;
  final String name;
  final String category; 
  final int coinsPerItem; 
  final String unit; 

  WasteTypeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.coinsPerItem,
    required this.unit,
  });

  factory WasteTypeModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WasteTypeModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Lainnya',
      coinsPerItem: (data['coinsPerItem'] as num?)?.toInt() ?? 0,
      unit: data['unit'] ?? 'Item',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'coinsPerItem': coinsPerItem,
      'unit': unit,
    };
  }
}