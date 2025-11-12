import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tixcycle/models/transaction_model.dart'; 

class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PurchasedTicketItem ticket = Get.arguments as PurchasedTicketItem;
    
    final String qrData = ticket.ticketId;

    return Scaffold(
      appBar: AppBar(title: Text("E-Ticket")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Pindai kode ini di pintu masuk", style: Get.textTheme.titleMedium),
              const SizedBox(height: 24),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 250.0,
                  gapless: false,
                ),
              ),
              const SizedBox(height: 24),
              Text("ID Tiket:", style: Get.textTheme.bodyMedium),
              Text(ticket.ticketId, style: Get.textTheme.titleSmall),
              const SizedBox(height: 16),
              Text("Kategori:", style: Get.textTheme.bodyMedium),
              Text(ticket.categoryName, style: Get.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text("Kursi:", style: Get.textTheme.bodyMedium),
              Text(ticket.seatNumber, style: Get.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}