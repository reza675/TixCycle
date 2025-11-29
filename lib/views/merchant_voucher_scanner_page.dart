import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/controllers/merchant_voucher_scanner_controller.dart';

class MerchantVoucherScannerPage extends StatefulWidget {
  const MerchantVoucherScannerPage({super.key});

  @override
  State<MerchantVoucherScannerPage> createState() =>
      _MerchantVoucherScannerPageState();
}

class _MerchantVoucherScannerPageState extends State<MerchantVoucherScannerPage>
    with WidgetsBindingObserver {
  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  MerchantVoucherScannerController get controller =>
      Get.find<MerchantVoucherScannerController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.cameraController.value.hasCameraPermission) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      controller.mulaiScanner();
    } else if (state == AppLifecycleState.inactive) {
      controller.hentikanScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2, c3, c4],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              _buildScannerView(),
              _buildTopBar(context),
              _buildScanOverlay(),
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Obx(
        () => controller.isScanning.value && !controller.isValidating.value
            ? MobileScanner(
                controller: controller.cameraController,
                onDetect: (capture) {
                  print("🎯 [VIEW] onDetect called in MobileScanner");
                  // Detection handled by controller's stream subscription
                },
              )
            : Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: c2,
                      ),
                      SizedBox(height: 16),
                      Text(
                        controller.isValidating.value
                            ? 'Memvalidasi voucher...'
                            : 'Memuat kamera...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c1.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: c4,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan Voucher',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Merchant Scanner',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    shadows: const [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(
            color: c2,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: c2.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Corner decorations
            Positioned(
              top: -2,
              left: -2,
              child: _buildCorner(),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Transform.rotate(
                angle: 1.5708,
                child: _buildCorner(),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Transform.rotate(
                angle: 3.14159,
                child: _buildCorner(),
              ),
            ),
            Positioned(
              bottom: -2,
              left: -2,
              child: Transform.rotate(
                angle: 4.71239,
                child: _buildCorner(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: c1, width: 4),
          left: BorderSide(color: c1, width: 4),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c1.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, color: c4, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Arahkan kamera ke QR Code voucher pelanggan',
                          style: TextStyle(
                            color: c4,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c2.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: c3, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sistem akan memvalidasi voucher secara otomatis',
                            style: TextStyle(
                              color: c3,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.flash_on,
                  label: 'Flash',
                  onTap: controller.toggleTorch,
                ),
                _buildControlButton(
                  icon: Icons.flip_camera_android,
                  label: 'Balik',
                  onTap: controller.switchCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: c1.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c3, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c4, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: c4,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
