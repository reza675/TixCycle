class PaymentMethodModel {
  final String id;
  final String name;
  final String logoUrl;
  final String category; // "Transfer Bank", "E-Wallet", "Gerai Retail", dll
  final String paymentInstructions;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.category,
    required this.paymentInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'category': category,
      'paymentInstructions': paymentInstructions,
    };
  }

}