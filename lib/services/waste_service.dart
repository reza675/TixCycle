import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/services/firestore_service.dart';

class WasteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService;

  final CollectionReference _wasteTypesRef =
      FirebaseFirestore.instance.collection('waste_types');
  
  final CollectionReference _voucherRef =
      FirebaseFirestore.instance.collection('waste_vouchers');
  
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('users');

  WasteService(this._firestoreService);

  
  Future<List<DocumentSnapshot>> getWasteTypes() async {
 
    return _firestoreService.getCollection(collectionPath: 'waste_types');
  }

  Future<String> createVoucher(Map<String, dynamic> data) async {

    try {
      final docRef = await _firestoreService.addData('waste_vouchers', data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }
  Future<int> claimVoucher(String voucherId, String userId) async {
    final voucherDocRef = _voucherRef.doc(voucherId);
    final userDocRef = _userRef.doc(userId);

    return _db.runTransaction((transaction) async {
      
      final voucherSnapshot = await transaction.get(voucherDocRef);
      if (!voucherSnapshot.exists) {
        throw Exception("Voucher tidak valid atau tidak ditemukan.");
      }
      final voucherData = voucherSnapshot.data() as Map<String, dynamic>;

      if (voucherData['isClaimed'] == true) {
        throw Exception("Voucher ini sudah digunakan.");
      }
      final Timestamp expiresAt = voucherData['expiresAt'];
      if (expiresAt.compareTo(Timestamp.now()) < 0) {
   
        throw Exception("Voucher sudah kedaluwarsa.");
      }

      final int coinsToAward = voucherData['totalCoins'];

      final userSnapshot = await transaction.get(userDocRef);
      if (!userSnapshot.exists) {
        throw Exception("Profil pengguna tidak ditemukan.");
      }
      final int currentCoins = (userSnapshot.data() as Map<String, dynamic>)['coins'] ?? 0;

      transaction.update(voucherDocRef, {
        'isClaimed': true,
        'claimedByUserId': userId,
      });
      transaction.update(userDocRef, {
        'coins': currentCoins + coinsToAward,
      });

      return coinsToAward;
    });
  }
}