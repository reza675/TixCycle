import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/my_vouchers_controller.dart';
import 'package:tixcycle/models/user_voucher_model.dart';
import 'package:tixcycle/routes/app_routes.dart';

class MyVouchersPage extends StatelessWidget {
  const MyVouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyVouchersController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3F5135)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Voucher Saya',
          style: TextStyle(
            color: Color(0xFF3F5135),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    controller: controller,
                    label: 'Semua',
                    index: 0,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    controller: controller,
                    label: 'Belum Dipakai',
                    index: 1,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    controller: controller,
                    label: 'Sudah Dipakai',
                    index: 2,
                  ),
                ),
              ],
            )),
          ),

          // Voucher List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredVouchers.isEmpty) {
                return _buildEmptyState(controller.selectedTab.value);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.loadMyVouchers();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.filteredVouchers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final voucher = controller.filteredVouchers[index];
                    return _buildVoucherCard(voucher);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required MyVouchersController controller,
    required String label,
    required int index,
  }) {
    final isSelected = controller.selectedTab.value == index;
    
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB3CC86) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF798E5E),
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherCard(UserVoucherModel voucher) {
    final isUsed = voucher.used;
    final isExpired = voucher.isExpired;
    final canUse = voucher.canUse;

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
            Get.toNamed(AppRoutes.MY_VOUCHER_DETAIL, arguments: voucher);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Voucher Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 60,
                        color: const Color(0xFFF5F5F5),
                        child: voucher.voucherImageUrl.isNotEmpty
                            ? ColorFiltered(
                                colorFilter: !canUse
                                    ? const ColorFilter.mode(
                                        Colors.grey,
                                        BlendMode.saturation,
                                      )
                                    : const ColorFilter.mode(
                                        Colors.transparent,
                                        BlendMode.multiply,
                                      ),
                                child: Image.network(
                                  voucher.voucherImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                ),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Voucher Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.voucherName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: canUse 
                                  ? const Color(0xFF3F5135)
                                  : Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Potongan Rp. ${voucher.discountAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: canUse 
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(isUsed, isExpired),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusText(isUsed, isExpired),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Purchase & Validity Info
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Ditukar: ${_formatDate(voucher.purchasedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Berlaku s/d ${_formatDate(voucher.validUntil)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isExpired ? Colors.red : Colors.grey[600],
                        fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: const Icon(
        Icons.card_giftcard,
        color: Color(0xFFB3CC86),
        size: 30,
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String message;
    switch (tabIndex) {
      case 1:
        message = 'Belum ada voucher yang belum dipakai';
        break;
      case 2:
        message = 'Belum ada voucher yang sudah dipakai';
        break;
      default:
        message = 'Belum ada voucher yang ditukar';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
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

  Color _getStatusColor(bool isUsed, bool isExpired) {
    if (isUsed) {
      return Colors.grey;
    } else if (isExpired) {
      return Colors.red;
    } else {
      return const Color(0xFF4CAF50);
    }
  }

  String _getStatusText(bool isUsed, bool isExpired) {
    if (isUsed) {
      return 'Terpakai';
    } else if (isExpired) {
      return 'Kedaluwarsa';
    } else {
      return 'Aktif';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
