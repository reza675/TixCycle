import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tixcycle/models/voucher_model.dart';
import 'package:tixcycle/services/supabase_storage_service.dart';

class VoucherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SupabaseStorageService _supabaseStorage;

  VoucherRepository(this._supabaseStorage);

  CollectionReference get _vouchersCollection =>
      _firestore.collection('vouchers');

  // Ambil semua vouchers yang available
  Stream<List<VoucherModel>> ambilSemuaVoucher() {
    return _vouchersCollection
        .where('stock', isGreaterThan: 0)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VoucherModel.fromSnapshot(doc))
            .toList());
  }

  // Get all vouchers (untuk KoinController)
  Future<List<VoucherModel>> getAllVouchers() async {
    try {
      print("=== FETCHING ALL VOUCHERS FROM FIRESTORE ===");
      final snapshot = await _vouchersCollection
          .orderBy('created_at', descending: true)
          .get();

      print("=== FOUND ${snapshot.docs.length} DOCUMENTS ===");
      final vouchers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        print("Voucher ID: ${doc.id}, Name: ${data?['name']}");
        return VoucherModel.fromSnapshot(doc);
      }).toList();

      return vouchers;
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
  /// Upload voucher image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String?> uploadVoucherImage(File imageFile, String voucherId) async {
    try {
      print("=== UPLOAD IMAGE TO SUPABASE START ===");
      print("Image path: ${imageFile.path}");
      print("Voucher ID: $voucherId");

      // Upload to Supabase Storage
      final imageUrl = await _supabaseStorage.uploadVoucherImage(
        imageFile: imageFile,
        voucherId: voucherId,
      );

      if (imageUrl != null) {
        print("=== UPLOAD SUCCESS: $imageUrl ===");
      } else {
        print("=== UPLOAD FAILED ===");
      }

      return imageUrl;
    } catch (e) {
      print("Error upload gambar voucher: $e");
      return null;
    }
  }

  // Hapus gambar voucher dari Supabase Storage
  Future<void> deleteVoucherImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('supabase')) {
        await _supabaseStorage.deleteVoucherImage(imageUrl);
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
  Future<bool> updateVoucher(
      String voucherId, Map<String, dynamic> data) async {
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

      if (imageUrl != null &&
          imageUrl.isNotEmpty &&
          imageUrl.contains('firebase')) {
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
