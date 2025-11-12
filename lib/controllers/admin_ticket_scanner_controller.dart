import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/repositories/ticket_validation_repository.dart';

class AdminTicketScannerController extends GetxController {
  final TicketValidationRepository _repository;
  AdminTicketScannerController(this._repository);

  final MobileScannerController cameraController = MobileScannerController();
  
  var isProcessing = false.obs;
  var resultMessage = ''.obs;
  var resultColor = Colors.grey.obs; 

  Future<void> onQRCodeDetected(BarcodeCapture capture) async {
    if (isProcessing.value) return;

    try {
      isProcessing(true);
      final String? ticketId = capture.barcodes.first.rawValue;
      if (ticketId == null || ticketId.isEmpty) {
        throw Exception("Kode QR kosong atau tidak valid.");
      }

      resultMessage.value = "Memvalidasi $ticketId...";
      resultColor.value = Colors.blue;
      
      final validationResult = await _repository.validateAndCheckInTicket(ticketId);
      
      if (validationResult.startsWith("SUKSES")) {
        resultColor.value = Colors.green;
      } else {
        resultColor.value = Colors.red;
      }
      resultMessage.value = validationResult;

    } catch (e) {
      resultColor.value = Colors.red;
      resultMessage.value = "Error: ${e.toString()}";
    }

    await Future.delayed(const Duration(seconds: 3));
    resultMessage.value = '';
    resultColor.value = Colors.grey;
    isProcessing(false);
  }
  
  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}