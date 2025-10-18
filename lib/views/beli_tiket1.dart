import 'package:flutter/material.dart';

class BeliTiket1 extends StatelessWidget {
  const BeliTiket1({super.key});

  // Warna yang konsisten dengan aplikasi (sama dengan beranda)
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
              fontWeight: FontWeight.w700,
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
                _buildTicketCard('GOLD', 'Rp280.000', 'Gold'),
                const SizedBox(height: 12),
                _buildTicketCard('VIP', 'Rp1.000.000', 'VIP'),
                const SizedBox(height: 12),
                _buildTicketCard('BRONZE', 'Rp350.000', 'Bronze'),
                const SizedBox(height: 12),
                _buildTicketCard('PLATINUM', 'Rp750.000', 'Platinum'),
                const SizedBox(height: 12),
                _buildTicketCard('VIP (PRESALE)', 'Rp800.000', 'VIP'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(String category, String price, String categoryName) {
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
                        color: c4,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: c2, width: 1),
                ),
                child: Text(
                  'Tambah',
                  style: TextStyle(
                    color: c4,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
