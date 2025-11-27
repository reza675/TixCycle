import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/models/waste_scan_model.dart';
import 'package:tixcycle/repositories/user_repository.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';

class ScanController extends GetxController {
  late MobileScannerController cameraController;
  StreamSubscription<Object?>? _subscription;
  final UserRepository _userRepository = Get.find<UserRepository>();

  var isScanning = true.obs;
  var scannedCode = ''.obs;
  var isTorchOn = false.obs;
  var cameraFacing = CameraFacing.back.obs;
  var lastScannedCode = ''.obs; // Track QR terakhir yang di-scan
  var isUpdatingCoins = false.obs;

  @override
  void onInit() {
    super.onInit();
    inisialisasiKamera();
  }

  void inisialisasiKamera() {
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.normal,
      autoStart: false, // Manual start untuk lifecycle management
    );

    // Start listening to barcode events
    _subscription = cameraController.barcodes.listen(_handleBarcode);

    // Start scanner
    unawaited(cameraController.start());
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    print("📷 _handleBarcode dipanggil");
    print("   - isScanning: ${isScanning.value}");

    if (!isScanning.value) {
      print("   ❌ Tidak proses karena isScanning = false");
      return;
    }

    final List<Barcode> barcodes = barcodeCapture.barcodes;

    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        print(
            "   ✅ Code terdeteksi: ${code.substring(0, code.length > 50 ? 50 : code.length)}...");
        print("   - lastScannedCode: ${lastScannedCode.value}");

        // Cek apakah QR Code berbeda dengan yang terakhir di-scan
        if (code != lastScannedCode.value) {
          print("   🔒 Set isScanning = false, simpan code");
          isScanning.value = false; 
          scannedCode.value = code;
          lastScannedCode.value = code;

          print("   🚀 Panggil prosesHasilScan()");
          prosesHasilScan(code);

        } else {
          print("   ⚠️ Duplikat scan, skip!");
        }
      }
    }
  }

  // lifecycle management dari luar (jika diperlukan)
  Future<void> mulaiScanner() async {
    if (!cameraController.value.hasCameraPermission) {
      return;
    }

    _subscription = cameraController.barcodes.listen(_handleBarcode);
    await cameraController.start();
  }

  Future<void> hentikanScanner() async {
    await _subscription?.cancel();
    _subscription = null;
    await cameraController.stop();
  }

  void prosesHasilScan(String code) {
    try {
      // Cek apakah QR Code adalah format waste/sampah
      if (WasteScanModel.isWasteQRCode(code)) {
        prosesWasteScan(code);
        return;
      }

      // Cek apakah code adalah URL event (format: /lihat_tiket/eventId atau eventId)
      if (code.contains('/lihat_tiket/')) {
        final eventId = code.split('/lihat_tiket/').last;
        navigasiKeEvent(eventId);
      } else if (code.startsWith('event_')) {
        final eventId = code.replaceFirst('event_', '');
        navigasiKeEvent(eventId);
      } else if (code.length == 20 || code.length == 28) {
        navigasiKeEvent(code);
      } else {
        Get.snackbar(
          'Hasil Scan',
          'QR Code: $code',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print("Error memproses hasil scan: $e");
      Get.snackbar(
        'Error',
        'Gagal memproses QR Code',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // proses waste scan
  void prosesWasteScan(String qrCode) async {
    try {
      final wasteScan = WasteScanModel.fromQRCode(qrCode);

      // Ambil user yang sedang login
      final userAccountController = Get.find<UserAccountController>();
      final userId = userAccountController.firebaseUser.value?.uid;

      if (userId == null) {
        Get.snackbar(
          'Error',
          'Anda harus login untuk mendapatkan coins',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        resetScanning();
        return;
      }

      // Update coins user
      isUpdatingCoins.value = true;

      // cek apakah QR Code sudah pernah di-scan
      final scanId = wasteScan.scanId;
      final alreadyScanned =
          await _userRepository.isQRCodeAlreadyScanned(scanId);

      if (alreadyScanned) {
        isUpdatingCoins.value = false;
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 28),
                SizedBox(width: 8),
                Text(
                  'QR Code Tidak Valid',
                  style: TextStyle(
                    color: Color(0xFF3F5135),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, size: 60, color: Colors.red[400]),
                SizedBox(height: 16),
                Text(
                  'QR Code ini sudah pernah di-scan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F5135),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Setiap QR Code hanya bisa digunakan satu kali. Silakan gunakan QR Code baru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    resetScanning();
                  });
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFF3F5135),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return;
      }

      // QR Code valid (belum pernah di-scan), lanjutkan proses
      try {
        await _userRepository.updateUserCoins(userId, wasteScan.totalPoints);

        // Simpan history scan (agar tidak bisa di-scan lagi)
        await _userRepository.saveWasteScanHistory(
          scanId: scanId,
          userId: userId,
          scanData: {
            'items': wasteScan.items.map((item) => item.toJson()).toList(),
            'total_points': wasteScan.totalPoints,
            'timestamp': wasteScan.timestamp.toIso8601String(),
          },
        );

        // Refresh user profile untuk update coins di UI
        await userAccountController.refreshUserProfile();

        tampilkanHasilWasteScan(wasteScan, coinsAdded: true);
      } catch (e) {
        print("❌ Error updating coins: $e");
        tampilkanHasilWasteScan(wasteScan,
            coinsAdded: false, error: e.toString());
      } finally {
        isUpdatingCoins.value = false;
      }
    } catch (e) {
      print("Error parsing waste QR: $e");
      Get.snackbar(
        'Error',
        'Format QR sampah tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      resetScanning();
    }
  }

  // Tampilkan dialog hasil waste scan
  void tampilkanHasilWasteScan(WasteScanModel wasteScan,
      {bool coinsAdded = false, String? error}) {
    String itemsDetail = '';
    for (var item in wasteScan.items) {
      itemsDetail +=
          '• ${item.name}: ${item.quantity}x (${item.totalPoints} poin)\n';
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.recycling, color: Color(0xFFB3CC86), size: 28),
            SizedBox(width: 8),
            Text(
              'Scan Berhasil!',
              style: TextStyle(
                color: Color(0xFF3F5135),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sampah yang dibuang:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F5135),
              ),
            ),
            SizedBox(height: 8),
            Text(itemsDetail.trim()),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Poin:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F5135),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFB3CC86),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${wasteScan.totalPoints}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: coinsAdded
                    ? Color(0xFFB3CC86).withOpacity(0.2)
                    : (error != null
                        ? Colors.red.withOpacity(0.1)
                        : Color(0xFFFFF8E2)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: coinsAdded
                      ? Color(0xFFB3CC86)
                      : (error != null ? Colors.red : Color(0xFFB3CC86)),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    coinsAdded
                        ? Icons.check_circle
                        : (error != null ? Icons.error : Icons.info_outline),
                    size: 20,
                    color: coinsAdded
                        ? Color(0xFF3F5135)
                        : (error != null ? Colors.red : Color(0xFF798E5E)),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      coinsAdded
                          ? '🎉 Coins berhasil ditambahkan ke akun Anda!'
                          : (error != null
                              ? '❌ Gagal menambahkan coins: ${error.length > 30 ? error.substring(0, 30) + "..." : error}'
                              : 'Coins sedang diproses...'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            coinsAdded ? FontWeight.bold : FontWeight.normal,
                        color: coinsAdded
                            ? Color(0xFF3F5135)
                            : (error != null
                                ? Colors.red[700]
                                : Color(0xFF798E5E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); 
              Future.delayed(const Duration(milliseconds: 300), () {
                print("🔄 Reset dari tombol OK");
                resetScanning();
              });
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF3F5135),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true, 
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        print("🔄 Reset dari .then()");
        resetScanning();
      });
    });
  }

  void navigasiKeEvent(String eventId) {
    Get.back(); 
    Get.toNamed(AppRoutes.LIHAT_TIKET.replaceAll(':id', eventId));
  }

  void toggleTorch() {
    isTorchOn.value = !isTorchOn.value;
    cameraController.toggleTorch();
  }

  void switchCamera() {
    cameraFacing.value = cameraFacing.value == CameraFacing.back
        ? CameraFacing.front
        : CameraFacing.back;
    cameraController.switchCamera();
  }

  void resetScanning() async {
    print("🔄 resetScanning() dipanggil");
    print("   - isScanning sebelum: ${isScanning.value}");
    print("   - lastScannedCode sebelum: $lastScannedCode");

    isScanning.value = true;
    scannedCode.value = '';
    lastScannedCode.value = ''; 

    print("   - isScanning sesudah: ${isScanning.value}");
    print("   - lastScannedCode sesudah: $lastScannedCode");

    print("   🔄 Restart camera...");
    try {
      await cameraController.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await cameraController.start();
      print("   ✅ Camera restarted!");
    } catch (e) {
      print("   ⚠️ Error restart camera: $e");
    }
  }

  @override
  Future<void> onClose() async {
    print("🔴 ScanController onClose() dipanggil");

    isScanning.value = false;
    await _subscription?.cancel();
    _subscription = null;

    try {
      await cameraController.stop();
      print("   ✅ Camera stopped");
    } catch (e) {
      print("   ⚠️ Error stopping camera: $e");
    }

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      await cameraController.dispose();
      print("   ✅ Camera disposed");
    } catch (e) {
      print("   ⚠️ Error disposing camera: $e");
    }

    super.onClose();
  }
}
