import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tixcycle/models/validation_result_model.dart';
import 'package:tixcycle/repositories/ticket_validation_repository.dart';

class AdminTicketScannerController extends GetxController {
  final TicketValidationRepository _repository;
  AdminTicketScannerController(this._repository);

  final MobileScannerController cameraController = MobileScannerController();
  
  var isProcessing = false.obs;
  var resultMessage = ''.obs;
  var resultColor = Colors.grey.obs; 
  var statusMessage = ''.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  final Rx<ValidationResultModel?> validationResult = Rx<ValidationResultModel?>(null);

  Future<void> onQRCodeDetected(BarcodeCapture capture) async {
    if (isProcessing.value) return;

    try {
      isProcessing(true);
      validationResult.value = null; 
      errorMessage.value = null; 

      final String? ticketId = capture.barcodes.first.rawValue;
      if (ticketId == null || ticketId.isEmpty) {
        throw Exception("Kode QR kosong atau tidak valid.");
      }

      statusMessage.value = "Memvalidasi $ticketId...";
      resultColor.value = Colors.blue;

      final resultData = await _repository.validateAndCheckInTicket(ticketId);

      validationResult.value = resultData; 
      resultColor.value = Colors.green;
      statusMessage.value = "Check-in SUKSES!";

    } on Exception catch (e) {

      resultColor.value = Colors.red;
      errorMessage.value =
          "Validasi Gagal: ${e.toString().replaceAll("Exception: ", "")}";
    } catch (e) {
      
      resultColor.value = Colors.red;
      errorMessage.value = "Error: ${e.toString()}";
    }

    await Future.delayed(const Duration(seconds: 5));
    statusMessage.value = '';
    resultColor.value = Colors.grey;
    validationResult.value = null;
    errorMessage.value = null;
    isProcessing(false);
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
