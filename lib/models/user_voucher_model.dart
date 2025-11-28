import 'package:cloud_firestore/cloud_firestore.dart';

class UserVoucherModel {
  final String id;
  final String voucherId;
  final String voucherName;
  final String voucherImageUrl;
  final int discountAmount;
  final String merchantName;
  final List<String> tataCara;
  final String qrCode;
  final DateTime purchasedAt;
  final DateTime validUntil;
  final bool used;
  final DateTime? usedAt;
  final int coinsSpent;

  UserVoucherModel({
    required this.id,
    required this.voucherId,
    required this.voucherName,
    required this.voucherImageUrl,
    required this.discountAmount,
    required this.merchantName,
    required this.tataCara,
    required this.qrCode,
    required this.purchasedAt,
    required this.validUntil,
    required this.used,
    this.usedAt,
    required this.coinsSpent,
  });

  factory UserVoucherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserVoucherModel(
      id: doc.id,
      voucherId: data['voucher_id'] ?? '',
      voucherName: data['voucher_name'] ?? '',
      voucherImageUrl: data['voucher_image_url'] ?? '',
      discountAmount: data['discount_amount'] ?? 0,
      merchantName: data['merchant_name'] ?? '',
      tataCara: (data['tata_cara'] as List<dynamic>?)?.cast<String>() ?? [],
      qrCode: data['qr_code'] ?? '',
      purchasedAt: (data['purchased_at'] as Timestamp).toDate(),
      validUntil: (data['valid_until'] as Timestamp).toDate(),
      used: data['used'] ?? false,
      usedAt: data['used_at'] != null 
          ? (data['used_at'] as Timestamp).toDate() 
          : null,
      coinsSpent: data['coins_spent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucher_id': voucherId,
      'voucher_name': voucherName,
      'voucher_image_url': voucherImageUrl,
      'discount_amount': discountAmount,
      'merchant_name': merchantName,
      'tata_cara': tataCara,
      'qr_code': qrCode,
      'purchased_at': Timestamp.fromDate(purchasedAt),
      'valid_until': Timestamp.fromDate(validUntil),
      'used': used,
      'used_at': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'coins_spent': coinsSpent,
    };
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get canUse => !used && !isExpired;
}
