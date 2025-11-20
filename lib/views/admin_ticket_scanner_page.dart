import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/controllers/admin_ticket_scanner_controller.dart';
import 'package:tixcycle/models/validation_result_model.dart';

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
                  color: controller.resultColor.value.withOpacity(0.95),
                  child: _buildFeedbackContent(), 
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackContent() {
    final ValidationResultModel? resultData = controller.validationResult.value;
    final String? errorMsg = controller.errorMessage.value;
    final String statusMsg = controller.statusMessage.value;

    String title;
    Widget content;

    if (resultData != null) {
      // --- TAMPILAN SUKSES (dengan data) ---
      title = statusMsg; // "Check-in SUKSES!"
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeedbackRow(
              "Nama Pembeli", resultData.transaction.customerDetails.name),
          _buildFeedbackRow("Event", resultData.event.name),
          _buildFeedbackRow("Tiket", resultData.ticket.categoryName),
          _buildFeedbackRow("Kursi", resultData.ticket.seatNumber),
        ],
      );
    } else if (errorMsg != null) {
      
      title = errorMsg; 
      content = const SizedBox.shrink();
    } else if (statusMsg.isNotEmpty) {
      
      title = statusMsg; 
      content = const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    } else {
      
      title = "Arahkan kamera ke QR Code tiket";
      content = const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (resultData != null ||
            (statusMsg.isNotEmpty && errorMsg == null)) ...[
          const Divider(color: Colors.white54, height: 24),
          content,
        ],
      ],
    );
  }

  Widget _buildFeedbackRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}