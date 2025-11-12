import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model untuk item sampah individual
class WasteItemModel {
  final String name;
  final int quantity;
  final int pointsPerItem;

  WasteItemModel({
    required this.name,
    required this.quantity,
    required this.pointsPerItem,
  });

  int get totalPoints => quantity * pointsPerItem;

  factory WasteItemModel.fromJson(Map<String, dynamic> json) {
    return WasteItemModel(
      name: json['name'] ?? json['jenis'] ?? '',
      quantity: (json['quantity'] ?? json['qty'] ?? json['jumlah'] ?? 0) as int,
      pointsPerItem: (json['points'] ?? json['poin'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'pointsPerItem': pointsPerItem,
      'totalPoints': totalPoints,
    };
  }
}

// Model untuk hasil scan sampah
class WasteScanModel {
  final String scanId;
  final DateTime timestamp;
  final List<WasteItemModel> items;
  final int totalPoints;
  final String? deviceId;

  WasteScanModel({
    required this.scanId,
    required this.timestamp,
    required this.items,
    required this.totalPoints,
    this.deviceId,
  });

  // Parse dari JSON string di QR Code
  factory WasteScanModel.fromQRCode(String qrData) {
    try {
      // Coba parse sebagai JSON
      final data = _parseJSON(qrData);
      if (data != null) {
        return WasteScanModel.fromJson(data);
      }

      // Jika bukan JSON, coba parse format string
      return WasteScanModel.fromString(qrData);
    } catch (e) {
      print("Error parsing QR Code: $e");
      rethrow;
    }
  }

  // Parse dari JSON
  factory WasteScanModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] ?? []) as List;
    final items = itemsList
        .map((item) => WasteItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return WasteScanModel(
      scanId: json['scan_id'] ??
          json['scanId'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      items: items,
      totalPoints: (json['total_points'] ??
          json['totalPoints'] ??
          json['total'] ??
          0) as int,
      deviceId: json['device_id'] ?? json['deviceId'],
    );
  }

  // Parse dari string format: waste|botol:2:5|makanan:1:10|total:15|device:IOT_001
  factory WasteScanModel.fromString(String qrData) {
    final parts = qrData.split('|');

    if (parts.isEmpty || parts[0].toLowerCase() != 'waste') {
      throw FormatException('Invalid waste QR format');
    }

    final List<WasteItemModel> items = [];
    int totalPoints = 0;
    String? deviceId;

    for (int i = 1; i < parts.length; i++) {
      final part = parts[i];

      if (part.startsWith('total:')) {
        totalPoints = int.parse(part.split(':')[1]);
      } else if (part.startsWith('device:')) {
        deviceId = part.split(':')[1];
      } else {
        // Format: nama:quantity:points
        final itemParts = part.split(':');
        if (itemParts.length >= 3) {
          items.add(WasteItemModel(
            name: itemParts[0],
            quantity: int.parse(itemParts[1]),
            pointsPerItem: int.parse(itemParts[2]),
          ));
        }
      }
    }

    // Jika total tidak ada di QR, hitung dari items
    if (totalPoints == 0) {
      totalPoints = items.fold(0, (sum, item) => sum + item.totalPoints);
    }

    return WasteScanModel(
      scanId: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      items: items,
      totalPoints: totalPoints,
      deviceId: deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'timestamp': Timestamp.fromDate(timestamp),
      'items': items.map((item) => item.toJson()).toList(),
      'totalPoints': totalPoints,
      'deviceId': deviceId,
    };
  }

  // Helper untuk cek apakah QR Code adalah format waste
  static bool isWasteQRCode(String qrData) {
    // Cek format string
    if (qrData.toLowerCase().startsWith('waste|')) {
      return true;
    }

    // Cek format JSON
    try {
      final data = _parseJSON(qrData);
      if (data != null &&
          (data['type'] == 'waste' ||
              data['type'] == 'waste_disposal' ||
              data.containsKey('items') && data.containsKey('total_points'))) {
        return true;
      }
    } catch (e) {
      return false;
    }

    return false;
  }

  // Helper untuk parse JSON
  static Map<String, dynamic>? _parseJSON(String str) {
    try {
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
