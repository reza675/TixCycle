import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/waste_type_model.dart'; 
import 'package:tixcycle/models/waste_voucher_model.dart'; 
import 'package:tixcycle/services/waste_service.dart';

class WasteRepository {
  final WasteService _service;
  WasteRepository(this._service);

  Future<List<WasteTypeModel>> getWasteTypes() async {
    try {
      final docs = await _service.getWasteTypes();
      return docs.map((doc) => WasteTypeModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching waste types: $e");
      rethrow;
    }
  }

  Future<String> createWasteVoucher({
    required List<Map<String, dynamic>> items,
    required int totalCoins,
    String? adminId,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 3));

      final newVoucher = WasteVoucherModel(
        id: '', 
        items: items,
        totalCoins: totalCoins,
        isClaimed: false,
        createdAt: Timestamp.fromDate(now),
        expiresAt: Timestamp.fromDate(expiresAt),
        createdByAdminId: adminId,
      );

      return _service.createVoucher(newVoucher.toJson());
    } catch (e) {
      print("Error creating waste voucher: $e");
      rethrow;
    }
  }

  Future<String> claimWasteVoucher(String voucherId, String userId) async {
    try {

      final int coinsWon = await _service.claimVoucher(voucherId, userId);

      return "Sukses! Anda mendapatkan $coinsWon koin.";
    } on Exception catch (e) {

      return "Gagal: ${e.toString().replaceAll("Exception: ", "")}";
    } catch (e) {
      return "Terjadi kesalahan tidak terduga. Silakan coba lagi.";
    }
  }
}