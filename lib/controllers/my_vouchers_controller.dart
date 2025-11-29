import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tixcycle/models/user_voucher_model.dart';

class MyVouchersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var myVouchers = <UserVoucherModel>[].obs;
  var isLoading = false.obs;
  var selectedTab = 0.obs;

  String? get _userId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    loadMyVouchers();
  }

  Future<void> loadMyVouchers() async {
    try {
      if (_userId == null) return;

      isLoading(true);
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('my_vouchers')
          .orderBy('purchased_at', descending: true)
          .get();

      myVouchers.value = snapshot.docs
          .map((doc) => UserVoucherModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error load my vouchers: $e");
      Get.snackbar('Error', 'Gagal memuat voucher Anda');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshVouchers() async {
    await loadMyVouchers();
  }

  List<UserVoucherModel> get filteredVouchers {
    if (selectedTab.value == 0) {
      // Semua
      return myVouchers;
    } else if (selectedTab.value == 1) {
      // Belum Dipakai
      return myVouchers.where((v) => !v.used && !isExpired(v)).toList();
    } else {
      // Sudah Dipakai / Kadaluarsa
      return myVouchers.where((v) => v.used || isExpired(v)).toList();
    }
  }

  bool isExpired(UserVoucherModel voucher) {
    return DateTime.now().isAfter(voucher.validUntil);
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
