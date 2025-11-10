import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/views/widgets/bottom_bar.dart'; 

// --- Palet Warna Sesuai Template ---
const Color c1_cream = Color(0xFFFFF8E2);
const Color c2_lightGreen = Color(0xFFB3CC86);
const Color c3_medGreen = Color(0xFF96AD72);
const Color c4_darkGreen = Color(0xFF3F5135);
const Color c5_lightCream = Color(0xFFECEDCB);
// ----------------------------------

// --- 1. Ubah menjadi StatefulWidget ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- 2. Tambahkan state untuk currentIndex ---
  // Indeks 4 adalah "Profil"
  int currentIndex = 4; 

  // --- 3. Salin & Modifikasi _handleNavigation dari beranda.dart ---
  void _handleNavigation(int index) {
    // Dapatkan controller
    final userAccountController = Get.find<UserAccountController>();
    final bool isLoggedIn = userAccountController.firebaseUser.value != null;

    // Cek jika halaman butuh login
    final halamanIndeks = [1, 2, 3, 4]; // Transaksi, Pindai, Koin, Profil
    if (halamanIndeks.contains(index) && !isLoggedIn) {
      Get.toNamed(AppRoutes.LOGIN);
      return;
    }

    // Navigasi jika beda halaman
    if (index == 0) {
      // Kembali ke Beranda
      Get.offAllNamed(AppRoutes.BERANDA);
    } else if (index == 4) {
      // Kita sudah di halaman Profil, tidak perlu navigasi
      setState(() {
        currentIndex = index;
      });
    } else {
      // Untuk Tombol Transaksi, Pindai, Koin (Halaman lain)
      Get.snackbar("Info", "Halaman ini belum diimplementasikan.");
      // setState(() {
      //   currentIndex = index;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. Dapatkan controller di dalam method build ---
    final UserAccountController controller = Get.find<UserAccountController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1_cream, c2_lightGreen, c3_medGreen, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Agar body tembus di belakang bottom bar
        
        // --- 5. Tambahkan Bottom Bar ---
        bottomNavigationBar: CurvedBottomBar(
          currentIndex: currentIndex,
          onTap: (i) => _handleNavigation(i),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CenterActionButton(
          onPressed: () => _handleNavigation(2),
        ),

        body: SafeArea(
          child: Builder(
            builder: (BuildContext newContext) { 
              return Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.userProfile.value == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Anda belum login"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
                          child: const Text("Login Sekarang"),
                        ),
                      ],
                    ),
                  );
                }

                final UserModel user = controller.userProfile.value!;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      
                      _buildManualAppBar(), 

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildProfileHeader(user), 
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              title: "Info Akun",
                              children: [
                                _buildInfoRow("No. Telepon",
                                    user.phoneNumber ?? "Belum diatur", "UBAH"),
                                _buildInfoRow(
                                    "Email", user.email, "UBAH"),
                                _buildInfoRow(
                                    "Tipe ID", "Belum diatur", "UBAH"), // Mock-up diubah
                                _buildInfoRow("Nomor Identitas", "Belum diatur",
                                    "UBAH"), // Mock-up diubah
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              title: "Info Pribadi",
                              buttonText: "UBAH",
                              onButtonPressed: () {},
                              children: [
                                _buildPersonalInfoItem(
                                    "Nama Lengkap", user.displayName),
                                _buildPersonalInfoItem(
                                    "Jenis Kelamin", "Belum diatur"), // Mock-up diubah
                                _buildPersonalInfoItem(
                                    "Tanggal Lahir",
                                    user.birthOfDate != null
                                        ? DateFormat('dd MMMM yyyy')
                                            .format(user.birthOfDate!.toDate())
                                        : "Belum diatur"),
                                _buildPersonalInfoItem(
                                    "Provinsi", user.province ?? "Belum diatur"),
                                _buildPersonalInfoItem("Kota / Kabupaten",
                                    "Belum diatur"), // Mock-up diubah
                                _buildPersonalInfoItem(
                                    "Pekerjaan", "Belum diatur"), // Mock-up diubah
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildLogoutButton(controller),
                            const SizedBox(height: 80), // Spasi untuk bottom bar
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
            }
          ),
        ),
      ),
    );
  }

  Widget _buildManualAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: c4_darkGreen),
            // Arahkan ke beranda jika 'back' ditekan dari profil
            onPressed: () => Get.offAllNamed(AppRoutes.BERANDA), 
          ),
          const Text(
            'Profile',
            style: TextStyle(
                color: c4_darkGreen,
                fontSize: 20, 
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4), 
            decoration: BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle,
              border: Border.all(
                color: c4_darkGreen, // Bingkai hijau tua
                width: 3,            
              ),
              boxShadow: [
                 BoxShadow(
                   color: c4_darkGreen.withOpacity(0.3),
                   blurRadius: 8,
                   offset: const Offset(0, 4),
                 )
              ]
            ),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (user.profileImageUrl != null &&
                          user.profileImageUrl!.isNotEmpty)
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: (user.profileImageUrl == null ||
                          user.profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: c3_medGreen)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: c3_medGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.link, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: c4_darkGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: c1_cream, // Wrapper dalam warna krem
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: c4_darkGreen),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
          if (buttonText != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c3_medGreen.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String buttonText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: c4_darkGreen, 
                      fontSize: 13,
                      fontWeight: FontWeight.bold // <-- Label Tebal
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementasi fungsi 'Ubah'
            },
            child: Text(
              buttonText,
              style: const TextStyle(
                  color: c3_medGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: c4_darkGreen, 
              fontSize: 14,
              fontWeight: FontWeight.bold // <-- Label Tebal
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(UserAccountController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await controller.signOut();
          Get.offAllNamed(AppRoutes.BERANDA); // Arahkan ke Beranda
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}