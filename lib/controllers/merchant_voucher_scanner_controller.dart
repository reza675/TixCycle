import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';

class MerchantVoucherScannerController extends GetxController {
  final VoucherRepository _voucherRepository;

  MerchantVoucherScannerController(this._voucherRepository);

  late MobileScannerController cameraController;
  StreamSubscription<Object?>? _subscription;

  var isScanning = true.obs;
  var scannedCode = ''.obs;
  var isTorchOn = false.obs;
  var cameraFacing = CameraFacing.back.obs;
  var lastScannedCode = ''.obs;
  var isValidating = false.obs;

  @override
  void onInit() {
    super.onInit();
    inisialisasiKamera();
  }

  void inisialisasiKamera() {
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates, // Prevent duplicate scans
      autoStart: false,
      returnImage: false, // Don't return images to reduce memory usage
    );

    _subscription = cameraController.barcodes.listen(_handleBarcode);

    unawaited(cameraController.start());
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (!isScanning.value || isValidating.value) {
      return;
    }

    final List<Barcode> barcodes = barcodeCapture.barcodes;

    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;

      if (code != null && code.isNotEmpty && code != lastScannedCode.value) {
        isScanning.value = false;
        scannedCode.value = code;
        lastScannedCode.value = code;
        validateVoucher(code);
      }
    }
  }

  Future<void> validateVoucher(String qrCode) async {
    try {
      isValidating.value = true;

      final result = await _voucherRepository.validateVoucherQRCode(qrCode);

      final bool isValid = result['valid'] ?? false;
      final String message = result['message'] ?? 'Tidak ada pesan';

      if (isValid) {
        final voucherData = result['voucherData'] as Map<String, dynamic>;
        _showConfirmationDialog(voucherData);
      } else {
        _showErrorDialog(message, result);
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan saat memvalidasi voucher', {});
    } finally {
      isValidating.value = false;
    }
  }

  void _showConfirmationDialog(Map<String, dynamic> voucherData) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Voucher Valid',
                style: TextStyle(
                  color: Color(0xFF3F5135),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.card_giftcard, size: 60, color: Color(0xFFB3CC86)),
            SizedBox(height: 16),
            _buildInfoRow('Voucher', voucherData['voucherName']),
            Divider(),
            _buildInfoRow('Merchant', voucherData['merchantName']),
            Divider(),
            _buildInfoRow(
              'Potongan',
              'Rp ${voucherData['discountAmount'].toStringAsFixed(0)}',
              valueColor: Color(0xFFB3CC86),
              valueBold: true,
            ),
            Divider(),
            _buildInfoRow(
              'Berlaku s/d',
              _formatDate(voucherData['validUntil'] as DateTime),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voucher ini dapat digunakan. Lanjutkan untuk menandai sebagai terpakai.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
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
              resetScanning();
            },
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await redeemVoucher(
                voucherData['userId'],
                voucherData['id'],
                voucherData['voucherName'],
                voucherData['discountAmount'],
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB3CC86),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Gunakan Voucher',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorDialog(String message, Map<String, dynamic> additionalInfo) {
    IconData icon = Icons.error_outline;
    Color color = Colors.red[700]!;
    String additionalText = '';

    if (message.contains('sudah digunakan')) {
      icon = Icons.block;
      if (additionalInfo['usedAt'] != null) {
        additionalText =
            '\n\nDigunakan pada: ${_formatDate(additionalInfo['usedAt'] as DateTime)}';
      }
    } else if (message.contains('kadaluwarsa')) {
      icon = Icons.access_time;
      color = Colors.orange[700]!;
      if (additionalInfo['validUntil'] != null) {
        additionalText =
            '\n\nKadaluwarsa pada: ${_formatDate(additionalInfo['validUntil'] as DateTime)}';
      }
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Voucher Tidak Valid',
                style: TextStyle(
                  color: Color(0xFF3F5135),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 60, color: color),
            SizedBox(height: 16),
            Text(
              message + additionalText,
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
              resetScanning();
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
  }

  Future<void> redeemVoucher(
    String userId,
    String voucherDocId,
    String voucherName,
    int discountAmount,
  ) async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFB3CC86)),
                  SizedBox(height: 16),
                  Text('Memproses voucher...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final success =
          await _voucherRepository.redeemVoucher(userId, voucherDocId);

      // Close loading
      Get.back();

      if (success) {
        // Show success dialog
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.celebration, color: Colors.green[700], size: 28),
                SizedBox(width: 8),
                Text(
                  'Berhasil!',
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
                Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
                SizedBox(height: 16),
                Text(
                  'Voucher berhasil digunakan!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F5135),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  voucherName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFB3CC86).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Potongan: Rp ${discountAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F5135),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  resetScanning();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB3CC86),
                  foregroundColor: Colors.white,
                ),
                child: Text('OK'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Error',
          'Gagal menggunakan voucher',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        resetScanning();
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      resetScanning();
    }
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Color(0xFF3F5135),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

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
    isScanning.value = true;
    scannedCode.value = '';
    lastScannedCode.value = '';
    isValidating.value = false;

    try {
      await cameraController.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await cameraController.start();
    } catch (e) {
      // Silently handle camera restart errors
    }
  }

  @override
  Future<void> onClose() async {
    isScanning.value = false;
    await _subscription?.cancel();
    _subscription = null;

    try {
      await cameraController.stop();
    } catch (e) {
      // Silently handle camera stop errors
    }

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      await cameraController.dispose();
    } catch (e) {
      // Silently handle camera dispose errors
    }

    super.onClose();
  }
}
