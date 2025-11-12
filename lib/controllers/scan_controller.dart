import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/models/waste_scan_model.dart';

class ScanController extends GetxController {
  late MobileScannerController cameraController;
  StreamSubscription<Object?>? _subscription;

  var isScanning = true.obs;
  var scannedCode = ''.obs;
  var isTorchOn = false.obs;
  var cameraFacing = CameraFacing.back.obs;
  var lastScannedCode = ''.obs; // Track QR terakhir yang di-scan

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
          isScanning.value = false; // Pause sementara untuk process
          scannedCode.value = code;
          lastScannedCode.value = code; // Simpan QR terakhir

          print("   🚀 Panggil prosesHasilScan()");
          prosesHasilScan(code);

          // Tidak perlu auto-reset karena akan di-reset manual dari dialog
        } else {
          print("   ⚠️ Duplikat scan, skip!");
        }
        // Jika QR sama dengan sebelumnya, diabaikan (no action)
      }
    }
  }

  // Method untuk lifecycle management dari luar (jika diperlukan)
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
        // Extract event ID dari URL
        final eventId = code.split('/lihat_tiket/').last;
        navigasiKeEvent(eventId);
      } else if (code.startsWith('event_')) {
        // Format: event_xxxxx
        final eventId = code.replaceFirst('event_', '');
        navigasiKeEvent(eventId);
      } else if (code.length == 20 || code.length == 28) {
        // Kemungkinan Firestore document ID (biasanya 20-28 karakter)
        navigasiKeEvent(code);
      } else {
        // Format tidak dikenali, tampilkan hasil scan (TIDAK tutup halaman!)
        Get.snackbar(
          'Hasil Scan',
          'QR Code: $code',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        // Tidak panggil Get.back() supaya bisa scan lagi!
      }
    } catch (e) {
      print("Error memproses hasil scan: $e");
      Get.snackbar(
        'Error',
        'Gagal memproses QR Code',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      // Tidak panggil Get.back() supaya bisa scan lagi!
    }
  }

  // Method baru untuk proses waste scan
  void prosesWasteScan(String qrCode) {
    try {
      final wasteScan = WasteScanModel.fromQRCode(qrCode);

      // Tampilkan dialog hasil scan
      tampilkanHasilWasteScan(wasteScan);

      // TODO: Nanti tambahkan logic update coins ke user
      // await updateUserCoins(wasteScan.totalPoints);
    } catch (e) {
      print("Error parsing waste QR: $e");
      Get.snackbar(
        'Error',
        'Format QR sampah tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // Tampilkan hasil scan sampah dengan detail
  void tampilkanHasilWasteScan(WasteScanModel wasteScan) {
    // Build detail items
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
            if (wasteScan.deviceId != null) ...[
              SizedBox(height: 8),
              Text(
                'Device: ${wasteScan.deviceId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFFFF8E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFB3CC86)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF798E5E)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Poin akan ditambahkan setelah fitur coin aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF798E5E),
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
              Get.back(); // Tutup dialog
              // Reset dengan delay untuk memastikan dialog sudah tertutup
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
      barrierDismissible: true, // Bisa ditutup dengan tap di luar
    ).then((_) {
      // Callback ketika dialog ditutup (baik dari tombol OK atau tap di luar)
      Future.delayed(const Duration(milliseconds: 300), () {
        print("🔄 Reset dari .then()");
        resetScanning();
      });
    });
  }

  void navigasiKeEvent(String eventId) {
    Get.back(); // Tutup halaman scan
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

    // Reset state
    isScanning.value = true;
    scannedCode.value = '';
    lastScannedCode.value = ''; // Reset lastScannedCode juga!

    print("   - isScanning sesudah: ${isScanning.value}");
    print("   - lastScannedCode sesudah: $lastScannedCode");

    // KUNCI: Restart camera untuk force detection ulang!
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
    // Stop listening to barcode events
    await _subscription?.cancel();
    _subscription = null;

    // Dispose controller
    await cameraController.dispose();
    super.onClose();
  }
}
