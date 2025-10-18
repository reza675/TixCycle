import 'package:flutter/material.dart';

class BeliTiket extends StatefulWidget {
  const BeliTiket({super.key});

  @override
  State<BeliTiket> createState() => _BeliTiketState();
}

class _BeliTiketState extends State<BeliTiket> {
  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  // Data tiket sementara doang
  final List<Map<String, dynamic>> availableTickets = [
    {
      'category': 'GOLD',
      'price': 280000,
      'categoryName': 'Gold',
    },
    {
      'category': 'VIP',
      'price': 1000000,
      'categoryName': 'VIP',
    },
    {
      'category': 'BRONZE',
      'price': 350000,
      'categoryName': 'Bronze',
    },
    {
      'category': 'PLATINUM',
      'price': 750000,
      'categoryName': 'Platinum',
    },
    {
      'category': 'VIP (PRESALE)',
      'price': 800000,
      'categoryName': 'VIP',
    },
  ];

  Map<String, int> selectedTickets = {};

  // Fungsi untuk menambah tiket
  void addTicket(String category) {
    setState(() {
      selectedTickets[category] = (selectedTickets[category] ?? 0) + 1;
    });
  }

  // Fungsi untuk mengurangi tiket
  void removeTicket(String category) {
    setState(() {
      if (selectedTickets[category] != null && selectedTickets[category]! > 0) {
        selectedTickets[category] = selectedTickets[category]! - 1;
        if (selectedTickets[category] == 0) {
          selectedTickets.remove(category);
        }
      }
    });
  }

  // Fungsi  total harga
  int getTotalPrice() {
    int total = 0;
    selectedTickets.forEach((category, quantity) {
      final ticket =
          availableTickets.firstWhere((t) => t['category'] == category);
      total += (ticket['price'] as int) * quantity;
    });
    return total;
  }

  // Fungsi jumlah tiket yang dipilih
  int getSelectedTicketCount() {
    return selectedTickets.values.fold(0, (sum, quantity) => sum + quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2, c3, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header dengan back button dan title
              _buildHeader(context),
              // Main content
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: c4,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'TixCycle',
            style: TextStyle(
              color: c4,
              fontSize: 28,
              fontWeight: FontWeight.w400,
              shadows: const [
                Shadow(
                    blurRadius: 10.0,
                    color: Colors.black26,
                    offset: Offset(4, 4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c2, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul utama
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pilih Tiket Anda',
              style: TextStyle(
                color: c4,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // List tiket
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...availableTickets.map((ticket) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTicketCard(
                        ticket['category'],
                        'Rp${ticket['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        ticket['categoryName'],
                      ),
                    )),
                const SizedBox(height: 20),
                // Summary tiket yang dipilih
                if (selectedTickets.isNotEmpty) _buildSelectedTicketsSummary(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(String category, String price, String categoryName) {
    final selectedCount = selectedTickets[category] ?? 0;
    final isSelected = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c2, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: Color(0xFF3F5135),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(4, 4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                          color: Color(0xFF314417),
                          fontSize: 14,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              // Tombol yang responsif
              Row(
                children: [
                  if (isSelected) ...[
                    // Tombol minus
                    GestureDetector(
                      onTap: () => removeTicket(category),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: c2, width: 1),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Jumlah tiket
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: c1,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: c2, width: 1),
                      ),
                      child: Text(
                        '$selectedCount',
                        style: TextStyle(
                          color: c4,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Tombol plus/tambah
                  GestureDetector(
                    onTap: () => addTicket(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? c2 : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: c2, width: 1),
                      ),
                      child: Text(
                        isSelected ? '+' : 'Tambah',
                        style: TextStyle(
                          color: isSelected ? Colors.white : c4,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Nikmati malam penuh nostalgia bersama band legendaris Ungu dengan tiket kategori $categoryName!',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // isi apayah bang wkwk
            },
            child: Text(
              'Tampilkan Lebih banyak',
              style: TextStyle(
                color: c2,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget  menampilkan summary tiket yang dipilih
  Widget _buildSelectedTicketsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c2, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiket yang Dipilih:',
            style: TextStyle(
              color: c4,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // List tiket yang dipilih
          ...selectedTickets.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entry.key}',
                    style: TextStyle(
                      color: c4,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${entry.value}x',
                    style: TextStyle(
                      color: c4,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(color: c2, thickness: 1),
          const SizedBox(height: 8),
          // Total harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total :',
                style: TextStyle(
                  color: c4,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp${getTotalPrice().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: TextStyle(
                  color: c4,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tombol Lanjutkan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to next page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Total: Rp${getTotalPrice().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'),
                    backgroundColor: c2,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: c2,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Lanjutkan',
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
  }
}
