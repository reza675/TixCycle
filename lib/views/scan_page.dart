import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/controllers/scan_controller.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  ScanController get controller => Get.find<ScanController>();

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Stop listening to lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it
    // Permission dialogs can trigger lifecycle changes before the controller is ready
    if (!controller.cameraController.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed
        controller.mulaiScanner();
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused
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
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Obx(() => controller.isScanning.value
        ? MobileScanner(
            controller: controller.cameraController,
            // onDetect tidak diperlukan karena sudah pakai stream subscription di controller
          )
        : Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: c2,
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
            const Text(
              'Scan QR Code',
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
                angle: 1.5708, // 90 degrees
                child: _buildCorner(),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees
                child: _buildCorner(),
              ),
            ),
            Positioned(
              bottom: -2,
              left: -2,
              child: Transform.rotate(
                angle: 4.71239, // 270 degrees
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

  Widget _buildBottomControls() {
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
            const Text(
              'Arahkan kamera ke QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black54,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
