import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tixcycle/models/coin_transaction_model.dart';
import 'package:tixcycle/models/user_voucher_model.dart';

class CoinRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Ambil saldo coin user
  Future<int> ambilSaldoCoin() async {
    try {
      if (_userId == null) return 0;

      final doc = await _firestore.collection('users').doc(_userId).get();
      if (!doc.exists) return 0;

      final data = doc.data();
      return data?['coins'] ?? 0;
    } catch (e) {
      print("Error ambil saldo coin: $e");
      return 0;
    }
  }

  // Update saldo coin (tambah atau kurang)
  Future<bool> updateSaldoCoin(int amount) async {
    try {
      if (_userId == null) return false;

      final userRef = _firestore.collection('users').doc(_userId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User tidak ditemukan");
        }

        final currentSaldo = snapshot.data()?['coins'] ?? 0;
        final newSaldo = currentSaldo + amount;

        if (newSaldo < 0) {
          throw Exception("Saldo tidak cukup");
        }

        transaction.update(userRef, {'coins': newSaldo});
      });

      return true;
    } catch (e) {
      print("Error update saldo coin: $e");
      return false;
    }
  }

  // Simpan transaksi coin
  Future<void> simpanTransaksi(CoinTransactionModel transaction) async {
    try {
      if (_userId == null) return;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('coin_transactions')
          .add(transaction.toJson());
    } catch (e) {
      print("Error simpan transaksi: $e");
    }
  }

  // Ambil history transaksi coin
  Stream<List<CoinTransactionModel>> ambilHistoryTransaksi() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('coin_transactions')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CoinTransactionModel.fromSnapshot(doc))
            .toList());
  }

  // Simpan voucher ke koleksi user (my_vouchers)
  Future<void> simpanVoucherKePengguna(UserVoucherModel voucher) async {
    try {
      if (_userId == null) return;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('my_vouchers')
          .add(voucher.toJson());
    } catch (e) {
      print("Error simpan voucher ke pengguna: $e");
      throw e;
    }
  }

  // Ambil voucher yang dimiliki user
  Stream<List<UserVoucherModel>> ambilVoucherPengguna() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('my_vouchers')
        .orderBy('purchased_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserVoucherModel.fromFirestore(doc))
            .toList());
  }
}
