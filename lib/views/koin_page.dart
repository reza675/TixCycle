import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/admin_voucher_controller.dart';
import 'package:tixcycle/controllers/koin_controller.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/voucher_model.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:tixcycle/views/widgets/admin_voucher_modal.dart';
import 'package:tixcycle/views/widgets/bottom_bar.dart';

class KoinPage extends StatefulWidget {
  const KoinPage({super.key});

  @override
  State<KoinPage> createState() => _KoinPageState();
}

class _KoinPageState extends State<KoinPage> {
  int currentIndex = 3; // Index untuk Koin di bottom navbar

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
      Get.toNamed(AppRoutes.MY_TICKETS);
    } else if (index == 2) {
      if (userAccountController.isAdmin) {
        Get.toNamed(AppRoutes.ADMIN_SCANNER);
      } else {
        Get.toNamed(AppRoutes.SCAN);
      }
    } else if (index == 3) {
      // Already on Koin page
      setState(() {
        currentIndex = index;
      });
    } else if (index == 4) {
      Get.toNamed(AppRoutes.PROFILE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KoinController>();
    final userController = Get.find<UserAccountController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E2),
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan tombol admin
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tukar Koin',
                      style: TextStyle(
                        color: Color(0xFF3F5135),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Obx(() {
                      if (userController.isAdmin) {
                        return IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Color(0xFF4CAF50), size: 32),
                          onPressed: () {
                            Get.dialog(const AdminVoucherModal());
                          },
                          tooltip: 'Tambah Voucher',
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSaldoKoinCard(controller),
                const SizedBox(height: 24),
                const Text(
                  'Voucher Tersedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F5135),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.voucherList.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.voucherList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final voucher = controller.voucherList[index];
                      return _buildVoucherCard(
                          context, voucher, controller, userController);
                    },
                  );
                }),
                const SizedBox(height: 100), // Space for bottom navbar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedBottomBar(
        currentIndex: currentIndex,
        onTap: (i) => _handleNavigation(i),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CenterActionButton(
        onPressed: () => _handleNavigation(2),
      ),
    );
  }

  Widget _buildSaldoKoinCard(KoinController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB3CC86), Color(0xFF798E5E)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Koin Saya :',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                    '${controller.saldoCoin} koin',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, VoucherModel voucher,
      KoinController controller, UserAccountController userController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB3CC86).withOpacity(0.3),
          width: 1,
        ),
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
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.toNamed(AppRoutes.DETAIL_VOUCHER, arguments: voucher);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    height: 70,
                    color: const Color(0xFFF5F5F5),
                    child: voucher.imageUrl.isNotEmpty
                        ? Image.network(
                            voucher.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F5135),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Potongan Harga Rp. ${voucher.discountAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  if (userController.isAdmin) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Color(0xFF4CAF50), size: 20),
                          onPressed: () {
                            Get.dialog(
                                AdminVoucherModal(voucherToEdit: voucher));
                          },
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          onPressed: () {
                            final adminController =
                                Get.find<AdminVoucherController>();
                            adminController.hapusVoucher(voucher);
                          },
                          tooltip: 'Hapus',
                        ),
                      ],
                    );
                  } else {
                    return InkWell(
                      onTap: () => _showKonfirmasiTukarDialog(
                          context, voucher, controller),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${voucher.priceCoins}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: const Icon(
        Icons.card_giftcard,
        color: Color(0xFFB3CC86),
        size: 40,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada voucher tersedia',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKonfirmasiTukarDialog(
      BuildContext context, VoucherModel voucher, KoinController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFF8E2),
                const Color(0xFFFFF8E2),
                const Color(0xFFB3CC86).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Konfirmasi Tukar Koin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F5135),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  color: const Color(0xFFF5F5F5),
                  child: voucher.imageUrl.isNotEmpty
                      ? Image.network(
                          voucher.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                voucher.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F5135),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB3CC86).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB3CC86).withOpacity(0.5),
                  ),
                ),
                child: Obx(() => Column(
                      children: [
                        _buildCoinInfoRow(
                          icon: Icons.monetization_on,
                          label: 'Harga',
                          value: '${voucher.priceCoins} koin',
                          color: const Color(0xFFFFD700),
                        ),
                        const Divider(height: 16),
                        _buildCoinInfoRow(
                          icon: Icons.account_balance_wallet,
                          label: 'Saldo Anda',
                          value: '${controller.saldoCoin} koin',
                          color: const Color(0xFF798E5E),
                        ),
                        const Divider(height: 16),
                        _buildCoinInfoRow(
                          icon: Icons.check_circle,
                          label: 'Sisa',
                          value:
                              '${controller.saldoCoin.value - voucher.priceCoins} koin',
                          color:
                              controller.saldoCoin.value >= voucher.priceCoins
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red,
                        ),
                      ],
                    )),
              ),
              const SizedBox(height: 16),
              Text(
                'Yakin ingin menukar voucher ini dengan ${voucher.priceCoins} koin?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3F5135),
                        side: const BorderSide(color: Color(0xFF798E5E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  final success =
                                      await controller.tukarVoucher(voucher);
                                  if (success) {
                                    Get.back();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB3CC86),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Tukar Sekarang',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: !controller.isLoading.value,
    );
  }

  Widget _buildCoinInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3F5135),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
