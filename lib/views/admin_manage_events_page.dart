import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/routes/app_routes.dart';

class AdminManageEventsPage extends StatelessWidget {
  const AdminManageEventsPage({super.key});

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
            'Kelola Data Tiket',
            style: TextStyle(
              color: c4,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildMenuCard(
                  title: "Tambah Data Tiket",
                  subtitle: "Buat event baru dan atur jenis tiket",
                  icon: Icons.add_circle_outline,
                  color: c4,
                  onTap: () {
                    Get.toNamed(AppRoutes.ADD_EVENT);
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  title: "Perbarui Data Tiket",
                  subtitle: "Edit informasi event atau stok tiket",
                  icon: Icons.edit_outlined,
                  color: c3, 
                  onTap: () {
              
                    Get.toNamed(AppRoutes.ADMIN_EVENT_LIST);
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  title: "Hapus Data Tiket",
                  subtitle: "Hapus event yang sudah tidak aktif",
                  icon: Icons.delete_outline,
                  color: Colors.red[700]!, // Warna merah untuk aksi destruktif
                  onTap: () {
                    Get.toNamed(AppRoutes.ADMIN_DELETE_EVENT_LIST);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}