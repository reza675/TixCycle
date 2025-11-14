import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/routes/app_routes.dart';

class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({Key? key}) : super(key: key);

  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final PurchasedTicketItem ticket;
    if (arguments is Map<String, dynamic>) {
      ticket = arguments['ticket'] as PurchasedTicketItem;
    } else {
      ticket = arguments as PurchasedTicketItem;
    }

    final String qrData = ticket.ticketId;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: c4),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Tampilan Kode QR",
            style: TextStyle(
              color: c4,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c1.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c3, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // QR Code dengan background putih dan heart icon
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        // Anda pasti memiliki Stack di sini
                        alignment: Alignment.center,
                        children: [
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 220.0,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.recycling,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 24),
                  // Info box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c3.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kode ini hanya berlaku 1x scan",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Button Selesai
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c3,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.MY_TICKETS);
                      },
                      child: const Text(
                        "Selesai",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
