import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tixcycle/controllers/ticket_detail_controller.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:intl/intl.dart';

// Ubah menjadi GetView<TicketDetailController>
class TicketDetailPage extends GetView<TicketDetailController> {
  const TicketDetailPage({Key? key}) : super(key: key);

  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  @override
  Widget build(BuildContext context) {
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
            "E-Ticket",
            style: TextStyle(
              color: c4,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final ticket = controller.ticketLive.value;
          if (ticket == null) {
            return const Center(child: Text("Data tiket tidak ditemukan"));
          }

          final bool isUsed = ticket.isCheckedIn;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: c1.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c3, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUsed)
                      Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                size: 60, color: Colors.green[700]),
                            const SizedBox(height: 16),
                            Text(
                              "TIKET SUDAH\nDIGUNAKAN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (ticket.checkInTime != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('dd MMM yyyy, HH:mm')
                                      .format(ticket.checkInTime!.toDate()),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              QrImageView(
                                data: ticket.id,
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
                    
                    
                    _buildTicketInfoRow("ID Tiket", ticket.id),
                    const Divider(height: 24),
                    _buildTicketInfoRow("Kategori", ticket.categoryName,
                        isBold: true, size: 18),
                    const SizedBox(height: 8),
                    _buildTicketInfoRow("Nomor Kursi", ticket.seatNumber,
                        isBold: true, size: 16),

                    const SizedBox(height: 32),
                    
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
                          "Kembali",
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
          );
        }),
      ),
    );
  }

  Widget _buildTicketInfoRow(String label, String value,
      {bool isBold = false, double size = 14}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: size,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: c4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}