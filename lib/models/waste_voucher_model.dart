import 'package:cloud_firestore/cloud_firestore.dart';

class WasteVoucherModel {
  final String id;
  final List<Map<String, dynamic>> items; 
  final int totalCoins;
  final bool isClaimed; 
  final Timestamp createdAt; 
  final Timestamp expiresAt; 
  final String? createdByAdminId;
  final String? claimedByUserId; 

  WasteVoucherModel({
    required this.id,
    required this.items,
    required this.totalCoins,
    this.isClaimed = false,
    required this.createdAt,
    required this.expiresAt,
    this.createdByAdminId,
    this.claimedByUserId,
  });

  factory WasteVoucherModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WasteVoucherModel(
      id: doc.id,
    
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalCoins: (data['totalCoins'] as num?)?.toInt() ?? 0,
      isClaimed: data['isClaimed'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'] ?? Timestamp.now(),
      createdByAdminId: data['createdByAdminId'],
      claimedByUserId: data['claimedByUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'totalCoins': totalCoins,
      'isClaimed': isClaimed,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'createdByAdminId': createdByAdminId,
      'claimedByUserId': claimedByUserId,
    };
  }
}