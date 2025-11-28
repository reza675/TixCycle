import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tixcycle/models/voucher_model.dart';

class VoucherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _vouchersCollection =>
      _firestore.collection('vouchers');

  // Ambil semua vouchers yang available
  Stream<List<VoucherModel>> ambilSemuaVoucher() {
    return _vouchersCollection
        .where('stock', isGreaterThan: 0)
        .orderBy('stock')
        .orderBy('price_coins')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VoucherModel.fromSnapshot(doc))
            .toList());
  }

  // Get all vouchers (untuk KoinController)
  Future<List<VoucherModel>> getAllVouchers() async {
    try {
      final snapshot = await _vouchersCollection
          .where('stock', isGreaterThan: 0)
          .orderBy('stock')
          .orderBy('price_coins')
          .get();
      
      return snapshot.docs
          .map((doc) => VoucherModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print("Error getAllVouchers: $e");
      return [];
    }
  }

  // Ambil voucher by ID
  Future<VoucherModel?> ambilVoucherById(String voucherId) async {
    try {
      final doc = await _vouchersCollection.doc(voucherId).get();
      if (doc.exists) {
        return VoucherModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print("Error ambil voucher by ID: $e");
      return null;
    }
  }

  // Alias method untuk compatibility
  Future<VoucherModel?> getVoucherById(String voucherId) async {
    return await ambilVoucherById(voucherId);
  }

  // Kurangi stock voucher setelah ditukar
  Future<bool> kurangiStockVoucher(String voucherId) async {
    try {
      final docRef = _vouchersCollection.doc(voucherId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("Voucher tidak ditemukan");
        }

        final data = snapshot.data() as Map<String, dynamic>?;
        final currentStock = data?['stock'] ?? 0;
        if (currentStock <= 0) {
          throw Exception("Stock voucher habis");
        }

        transaction.update(docRef, {'stock': currentStock - 1});
      });

      return true;
    } catch (e) {
      print("Error kurangi stock voucher: $e");
      return false;
    }
  }

  // Ambil vouchers by category
  Stream<List<VoucherModel>> ambilVoucherByCategory(String category) {
    return _vouchersCollection
        .where('category', isEqualTo: category)
        .where('stock', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VoucherModel.fromSnapshot(doc))
            .toList());
  }

  // Upload gambar voucher ke Firebase Storage
  Future<String?> uploadVoucherImage(File imageFile, String voucherId) async {
    try {
      final fileName = 'vouchers/${voucherId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print("Error upload gambar voucher: $e");
      return null;
    }
  }

  // Hapus gambar voucher dari Firebase Storage
  Future<void> deleteVoucherImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('firebase')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      print("Error hapus gambar voucher: $e");
    }
  }

  // Tambah voucher baru
  Future<String?> tambahVoucher(VoucherModel voucher) async {
    try {
      final docRef = await _vouchersCollection.add(voucher.toJson());
      return docRef.id;
    } catch (e) {
      print("Error tambah voucher: $e");
      return null;
    }
  }

  // Tambah voucher (alias untuk AdminVoucherController)
  Future<void> createVoucher(VoucherModel voucher) async {
    try {
      await _vouchersCollection.add(voucher.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan voucher: $e');
    }
  }

  // Update voucher
  Future<bool> updateVoucher(String voucherId, Map<String, dynamic> data) async {
    try {
      await _vouchersCollection.doc(voucherId).update(data);
      return true;
    } catch (e) {
      print("Error update voucher: $e");
      return false;
    }
  }

  // Hapus voucher
  Future<bool> hapusVoucher(String voucherId) async {
    try {
      final doc = await _vouchersCollection.doc(voucherId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final imageUrl = data['image_url'] as String?;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          await deleteVoucherImage(imageUrl);
        }
      }

      await _vouchersCollection.doc(voucherId).delete();
      return true;
    } catch (e) {
      print("Error hapus voucher: $e");
      return false;
    }
  }

  // Hapus voucher (alias untuk AdminVoucherController)
  Future<void> deleteVoucher(String voucherId) async {
    try {
      final doc = await _vouchersCollection.doc(voucherId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final imageUrl = data?['image_url'] as String?;

      if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.contains('firebase')) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Gagal hapus image: $e');
        }
      }

      await _vouchersCollection.doc(voucherId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus voucher: $e');
    }
  }

  // Ambil semua vouchers (termasuk yang stock habis) - untuk admin
  Stream<List<VoucherModel>> ambilSemuaVoucherAdmin() {
    return _vouchersCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VoucherModel.fromSnapshot(doc))
            .toList());
  }
}
