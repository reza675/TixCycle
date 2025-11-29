import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/views/widgets/bottom_bar.dart';

const Color c1_cream = Color(0xFFFFF8E2);
const Color c2_lightGreen = Color(0xFFB3CC86);
const Color c3_medGreen = Color(0xFF96AD72);
const Color c4_darkGreen = Color(0xFF3F5135);
const Color c5_lightCream = Color(0xFFECEDCB);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentIndex = 4;

  void _handleNavigation(int index) {
    final userAccountController = Get.find<UserAccountController>();
    final bool isLoggedIn = userAccountController.firebaseUser.value != null;

    final halamanIndeks = [1, 2, 3, 4];
    if (halamanIndeks.contains(index) && !isLoggedIn) {
      Get.toNamed(AppRoutes.LOGIN);
      return;
    }

    if (index == 0) {
      Get.offAllNamed(AppRoutes.BERANDA);
    } else if (index == 1) {
      Get.offAllNamed(AppRoutes.MY_TICKETS);
    } else if (index == 2) {
      if (userAccountController.isAdmin) {
        Get.toNamed(AppRoutes.ADMIN_SCANNER);
      } else {
        Get.toNamed(AppRoutes.SCAN);
      }
    } else if (index == 3) {
      Get.toNamed(AppRoutes.KOIN);
    } else if (index == 4) {
      setState(() {
        currentIndex = index;
      });
    } else {
      Get.snackbar("Info", "Halaman ini belum diimplementasikan.");
    }
  }

  @override
  Widget build(BuildContext context) {
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
        extendBody: true,
        bottomNavigationBar: CurvedBottomBar(
          currentIndex: currentIndex,
          onTap: (i) => _handleNavigation(i),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CenterActionButton(
          onPressed: () => _handleNavigation(2),
        ),
        body: SafeArea(
          child: Builder(builder: (BuildContext newContext) {
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

              if (controller.isAdmin) {
                return _buildAdminProfileBody(newContext, controller, user);
              } else {
                return _buildUserProfileBody(newContext, controller, user);
              }
            });
          }),
        ),
      ),
    );
  }

  Widget _buildUserProfileBody(BuildContext newContext,
      UserAccountController controller, UserModel user) {
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
                _buildProfileHeader(user, controller),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: "Info Akun",
                  children: [
                    _buildPersonalInfoItem(
                        "No. Telepon", user.phoneNumber ?? "Belum diatur"),
                    _buildPersonalInfoItem("Email", user.email),
                    _buildPersonalInfoItem(
                        "Tipe ID", user.idType ?? "Belum diatur"),
                    _buildPersonalInfoItem(
                        "Nomor Identitas", user.idNumber ?? "Belum diatur"),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: "Info Pribadi",
                  buttonText: "UBAH",
                  onButtonPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                  children: [
                    _buildPersonalInfoItem("Nama Lengkap", user.displayName),
                    _buildPersonalInfoItem(
                        "Jenis Kelamin", user.gender ?? "Belum diatur"),
                    _buildPersonalInfoItem(
                        "Tanggal Lahir",
                        user.birthOfDate != null
                            ? DateFormat('dd MMMM yyyy')
                                .format(user.birthOfDate!.toDate())
                            : "Belum diatur"),
                    _buildPersonalInfoItem(
                        "Provinsi", user.province ?? "Belum diatur"),
                    _buildPersonalInfoItem(
                        "Kota / Kabupaten", user.city ?? "Belum diatur"),
                    _buildPersonalInfoItem(
                        "Pekerjaan", user.occupation ?? "Belum diatur"),
                  ],
                ),
                const SizedBox(height: 24),
                _buildMenuButton(
                  icon: Icons.card_giftcard,
                  text: "Voucher Saya",
                  onPressed: () => Get.toNamed(AppRoutes.MY_VOUCHERS),
                ),
                const SizedBox(height: 32),
                _buildLogoutButton(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfileBody(BuildContext newContext,
      UserAccountController controller, UserModel user) {
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
                _buildProfileHeader(user, controller),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: "Info Akun",
                  buttonText: "UBAH",
                  onButtonPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                  children: [
                    _buildPersonalInfoItem("Email", user.email),
                    _buildPersonalInfoItem(
                        "Tipe ID", user.idType ?? "Belum diatur"),
                    _buildPersonalInfoItem(
                        "Nomor Identitas", user.idNumber ?? "Belum diatur"),
                  ],
                ),
                const SizedBox(height: 24),
                _buildAdminButton(
                    text: "Kelola Data Tiket",
                    onPressed: () {
                      Get.toNamed(AppRoutes.ADMIN_MANAGE_EVENTS);
                    }),
                const SizedBox(height: 16),
                _buildAdminButton(
                    text: "Scan Voucher Pelanggan",
                    icon: Icons.qr_code_scanner,
                    onPressed: () {
                      Get.toNamed(AppRoutes.MERCHANT_VOUCHER_SCANNER);
                    }),
                const SizedBox(height: 16),
                _buildAdminButton(
                    text: "QR Code Sampah",
                    onPressed: () {
                      Get.toNamed(AppRoutes.ADMIN_WASTE_QR);
                    }),
                const SizedBox(height: 32),
                _buildLogoutButton(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
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
            onPressed: () => Get.offAllNamed(AppRoutes.BERANDA),
          ),
          const Text(
            'Profile',
            style: TextStyle(
                color: c4_darkGreen, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, UserAccountController controller) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: c4_darkGreen,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: c4_darkGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]),
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
                  child: GestureDetector(
                    onTap: controller.changeProfilePicture,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: c3_medGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Image(
                        image: const AssetImage('images/profile/canvas.png'),
                        height: 16,
                        width: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: c4_darkGreen),
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
        color: c1_cream,
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

  Widget _buildPersonalInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: c4_darkGreen, fontSize: 14, fontWeight: FontWeight.bold),
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
          Get.offAllNamed(AppRoutes.BERANDA);
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

  Widget _buildAdminButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: c3_medGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: c1_cream,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c3_medGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: c4_darkGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: c4_darkGreen,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: c4_darkGreen,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
