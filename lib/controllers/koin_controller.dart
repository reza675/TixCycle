import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/models/coin_transaction_model.dart';
import 'package:tixcycle/models/user_voucher_model.dart';
import 'package:tixcycle/models/voucher_model.dart';
import 'package:tixcycle/repositories/coin_repository.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';

class KoinController extends GetxController {
  final CoinRepository coinRepository;
  final VoucherRepository voucherRepository;

  KoinController(this.coinRepository, this.voucherRepository);

  var saldoCoin = 0.obs;
  var voucherList = <VoucherModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSaldoCoin();
    loadVouchers();
  }

  Future<void> loadSaldoCoin() async {
    try {
      final saldo = await coinRepository.ambilSaldoCoin();
      saldoCoin.value = saldo;
    } catch (e) {
      print("Error load saldo coin: $e");
    }
  }

  Future<void> loadVouchers() async {
    try {
      isLoading(true);
      final vouchers = await voucherRepository.getAllVouchers();
      voucherList.assignAll(vouchers);
    } catch (e) {
      print("Error load vouchers: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    await loadSaldoCoin();
    await loadVouchers();
  }

  Future<bool> tukarVoucher(VoucherModel voucher) async {
    try {
      isLoading.value = true;

      // 1. Validasi saldo coin
      if (saldoCoin.value < voucher.priceCoins) {
        Get.snackbar(
          'Saldo Tidak Cukup',
          'Koin Anda tidak cukup untuk menukar voucher ini',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return false;
      }

      // 2. Validasi stock voucher
      final latestVoucher = await voucherRepository.getVoucherById(voucher.id);
      if (latestVoucher == null || latestVoucher.stock <= 0) {
        Get.snackbar(
          'Stock Habis',
          'Maaf, voucher ini sudah habis',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return false;
      }

      // 3. Kurangi saldo coin
      final updateSaldoSuccess =
          await coinRepository.updateSaldoCoin(-voucher.priceCoins);
      if (!updateSaldoSuccess) {
        Get.snackbar(
          'Gagal',
          'Gagal memperbarui saldo coin',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return false;
      }

      // 4. Kurangi stock voucher
      final updateStockSuccess =
          await voucherRepository.kurangiStockVoucher(voucher.id);
      if (!updateStockSuccess) {
        // Rollback: kembalikan coin jika gagal kurangi stock
        await coinRepository.updateSaldoCoin(voucher.priceCoins);
        Get.snackbar(
          'Gagal',
          'Gagal memperbarui stock voucher',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return false;
      }

      // 5. Simpan transaksi ke history
      final transaction = CoinTransactionModel(
        id: '',
        type: 'spend',
        amount: -voucher.priceCoins,
        description: 'Tukar voucher: ${voucher.name}',
        voucherId: voucher.id,
        createdAt: DateTime.now(),
      );
      await coinRepository.simpanTransaksi(transaction);

      // 6. Simpan voucher ke koleksi user (my_vouchers subcollection)
      final qrCode = 'VOUCHER-TXC-${DateTime.now().millisecondsSinceEpoch}';
      final userVoucher = UserVoucherModel(
        id: '',
        voucherId: voucher.id,
        voucherName: voucher.name,
        voucherImageUrl: voucher.imageUrl,
        discountAmount: voucher.discountAmount,
        merchantName: voucher.merchantName,
        tataCara: voucher.tataCara,
        qrCode: qrCode,
        purchasedAt: DateTime.now(),
        validUntil:
            voucher.validUntil ?? DateTime.now().add(Duration(days: 30)),
        used: false,
        coinsSpent: voucher.priceCoins,
      );
      await coinRepository.simpanVoucherKePengguna(userVoucher);

      // 7. Refresh data
      await refreshData();

      // 8. Tampilkan success message
      Get.snackbar(
        'Berhasil! 🎉',
        'Voucher berhasil ditukar! Cek di menu Voucher Saya',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFFB3CC86).withOpacity(0.9),
        colorText: Color(0xFF3F5135),
        icon: Icon(Icons.check_circle, color: Color(0xFF3F5135)),
        duration: Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      print("Error tukar voucher: $e");
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menukar voucher',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String get formattedSaldo => '$saldoCoin koin';

  List<VoucherModel> getVouchersByCategory(String category) {
    return voucherList.where((v) => v.category == category).toList();
  }
}
