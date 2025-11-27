import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;
  final String _collectionPath = 'users';
  UserRepository(this._firestoreService);

  Future<void> buatProfilUser(UserModel user) async {
    await _firestoreService.setData(
        path: '$_collectionPath/${user.id}', data: user.toJson());
  }

  Future<UserModel> ambilProfilUser(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestoreService.getDocument(path: '$_collectionPath/$userId');
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      } else {
        throw Exception("User profile not found");
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateProfilUser(
      String userId, Map<String, dynamic> data) async {
    await _firestoreService.updateData(
        path: '$_collectionPath/$userId', data: data);
  }

  // Update coins user
  Future<void> updateUserCoins(String userId, int coinsToAdd) async {
    try {
      final userDoc =
          await _firestoreService.getDocument(path: '$_collectionPath/$userId');

      if (!userDoc.exists) {
        throw Exception('User tidak ditemukan');
      }

      final currentCoins =
          (userDoc.data() as Map<String, dynamic>)['coins'] as int? ?? 0;
      final newCoins = currentCoins + coinsToAdd;

      // Update ke Firestore
      await _firestoreService.updateData(
        path: '$_collectionPath/$userId',
        data: {'coins': newCoins},
      );

      print('✅ Coins updated: $currentCoins + $coinsToAdd = $newCoins');
    } catch (e) {
      print('❌ Error updating coins: $e');
      rethrow;
    }
  }

  // Cek apakah QR Code sudah pernah di-scan (untuk QR sekali pakai)
  Future<bool> isQRCodeAlreadyScanned(String scanId) async {
    try {
      final doc =
          await _firestoreService.getDocument(path: 'waste_scans/$scanId');
      return doc.exists;
    } catch (e) {
      print('⚠️ Error checking scan history: $e');
      return false; // Jika error, anggap belum pernah di-scan (safe fallback)
    }
  }

  // Simpan history scan waste (untuk tracking & validasi QR sekali pakai)
  Future<void> saveWasteScanHistory({
    required String scanId,
    required String userId,
    required Map<String, dynamic> scanData,
  }) async {
    try {
      final data = {
        'scanId': scanId,
        'userId': userId,
        'scannedAt': FieldValue.serverTimestamp(),
        'items': scanData['items'],
        'totalPoints': scanData['total_points'],
        'timestamp': scanData['timestamp'],
      };

      await _firestoreService.setData(
        path: 'waste_scans/$scanId',
        data: data,
      );

      print('✅ Waste scan history saved: $scanId');
    } catch (e) {
      print('❌ Error saving scan history: $e');
      rethrow;
    }
  }
}
