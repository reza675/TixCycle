import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/controllers/admin_ticket_scanner_controller.dart';

class AdminTicketScannerPage extends GetView<AdminTicketScannerController> {
  const AdminTicketScannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pindai Tiket Masuk")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Tampilan Kamera
          MobileScanner(
            controller: controller.cameraController,
            onDetect: controller.onQRCodeDetected,
          ),
          
          // Bingkai Pemandu
          Container(
            width: Get.width * 0.7,
            height: Get.width * 0.7,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Tampilan Hasil (Feedback)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  color: controller.resultColor.value.withOpacity(0.9),
                  child: Text(
                    controller.resultMessage.value.isEmpty
                        ? "Arahkan kamera ke QR Code tiket"
                        : controller.resultMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}