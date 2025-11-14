import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/my_tickets_controller.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:tixcycle/views/widgets/bottom_bar.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({Key? key}) : super(key: key);

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {

  MyTicketsController controller = Get.find<MyTicketsController>();
  int currentIndex = 1;
  String selectedFilter = 'Semua';

  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  void _handleNavigation(int index) {
    if (index == 0) {
      Get.offAllNamed(AppRoutes.BERANDA);
    } else if (index == 1) {
      setState(() {
        currentIndex = index;
      });
    } else if (index == 2) {
      Get.snackbar("Info", "Fitur Scan belum diimplementasikan.");
    } else if (index == 4) {
      Get.offAllNamed(AppRoutes.PROFILE);
    } else {
      Get.snackbar("Info", "Halaman ini belum diimplementasikan.");
    }
  }

  List<String> _getAvailableMonths(List<TransactionModel> transactions) {
    final months = <String>{};
    for (var transaction in transactions) {
      final month =
          DateFormat('MMMM', 'id_ID').format(transaction.createdAt.toDate());
      months.add(month);
    }
    final sortedMonths = months.toList();
    sortedMonths.sort((a, b) {
      final monthsOrder = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return monthsOrder.indexOf(b).compareTo(monthsOrder.indexOf(a));
    });
    return ['Semua', ...sortedMonths];
  }

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
            onPressed: () {
              Get.offAllNamed(AppRoutes.BERANDA);
            },
          ),
          title: const Text(
            "Transaksi",
            style: TextStyle(
              color: c4,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        extendBody: true,
        bottomNavigationBar: CurvedBottomBar(
          currentIndex: currentIndex,
          onTap: (i) => _handleNavigation(i),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CenterActionButton(
          onPressed: () => _handleNavigation(2),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Anda belum memiliki tiket.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildFilterTabs(controller),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildTransactionList(controller),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      "Riwayat Transaksi",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: c4,
      ),
    );
  }

  Widget _buildFilterTabs(MyTicketsController controller) {
    final filters = _getAvailableMonths(controller.transactions);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: c3,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : c4,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? c3 : c3,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(MyTicketsController controller) {
    List<TransactionModel> filteredTransactions = controller.transactions;

    if (selectedFilter != 'Semua') {
      filteredTransactions = controller.transactions.where((transaction) {
        final month =
            DateFormat('MMMM', 'id_ID').format(transaction.createdAt.toDate());
        return month.toLowerCase() == selectedFilter.toLowerCase();
      }).toList();
    }

    
    if (filteredTransactions.isEmpty && selectedFilter != 'Semua') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Anda tidak memesan tiket\npada bulan ini",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100.0),
      itemCount: filteredTransactions.length + 1,
      itemBuilder: (context, index) {
        if (index == filteredTransactions.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c2,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.toNamed(AppRoutes.PENCARIAN_TIKET);
                },
                child: const Text(
                  "Tambah Tiket",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }
        final transaction = filteredTransactions[index];
        return _buildTransactionItem(transaction, index);
      },
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction, int index) {
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
        .format(transaction.createdAt.toDate());

    return FutureBuilder<EventModel?>(
      future: controller.getEventById(transaction.eventId),
      builder: (context, snapshot) {
        var eventName = 'Memuat event...';
        if (snapshot.connectionState == ConnectionState.done) {
          eventName = snapshot.data?.name ?? 'Event Tidak Ditemukan';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header transaksi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c1.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: c4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(transaction.status),
                  ],
                ),
              ),

              // Content transaksi - List semua tiket
              Container(
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tiket Saya",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: c4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // List semua tiket dengan button individual
                    ...transaction.purchasedItems.map((ticket) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c1.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detail Tiket",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: c4,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tipe Tiket",
                                  style: TextStyle(fontSize: 13, color: c4),
                                ),
                                Text(
                                  ticket.categoryName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: c4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Nomor Kursi",
                                  style: TextStyle(fontSize: 13, color: c4),
                                ),
                                Text(
                                  ticket.seatNumber,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: c4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Harga",
                                  style: TextStyle(fontSize: 13, color: c4),
                                ),
                                Text(
                                  "RP${ticket.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: c4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c3,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  Get.toNamed(
                                    AppRoutes.TICKET_DETAIL,
                                    arguments: ticket,
                                  );
                                },
                                child: const Text(
                                  "Lihat QR Tiket",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Selesai';
        break;
      case 'pending':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'Pending';
        break;
      case 'cancelled':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Dibatalkan';
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}