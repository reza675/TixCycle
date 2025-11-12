import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/my_tickets_controller.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/routes/app_routes.dart'; 
import 'package:intl/intl.dart';

class MyTicketsPage extends GetView<MyTicketsController> {
  const MyTicketsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tiket Saya")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.transactions.isEmpty) {
          return const Center(child: Text("Anda belum memiliki tiket."));
        }
        
        return ListView.builder(
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final transaction = controller.transactions[index];
            return _buildTransactionCard(context, transaction);
          },
        );
      }),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel transaction) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text("Pesanan #${transaction.id.substring(0, 6)}..."),
        subtitle: Text("Total: Rp ${transaction.totalAmount.toStringAsFixed(0)}"),
        children: [
          ...transaction.purchasedItems.map((ticket) {
            return ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(ticket.categoryName),
              subtitle: Text("Kursi: ${ticket.seatNumber}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.toNamed(
                  AppRoutes.TICKET_DETAIL, 
                  arguments: ticket,
                );
              },
            );
          }).toList()
        ],
      ),
    );
  }
}