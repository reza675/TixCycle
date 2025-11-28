import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tixcycle/controllers/my_voucher_detail_controller.dart';

class MyVoucherDetailPage extends StatelessWidget {
  const MyVoucherDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyVoucherDetailController>();
    final voucher = controller.voucher.value;

    if (voucher == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E2),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF8E2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3F5135)),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text('Voucher tidak ditemukan'),
        ),
      );
    }

    final canUse = voucher.canUse;
    final isUsed = voucher.used;
    final isExpired = voucher.isExpired;

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
          'Detail Voucher Saya',
          style: TextStyle(
            color: Color(0xFF3F5135),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Banner
            if (!canUse)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: isUsed ? Colors.grey : Colors.red,
                child: Text(
                  isUsed ? 'VOUCHER SUDAH DIGUNAKAN' : 'VOUCHER KEDALUWARSA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Code Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFB3CC86),
                              width: 2,
                            ),
                          ),
                          child: ColorFiltered(
                            colorFilter: !canUse
                                ? const ColorFilter.mode(
                                    Colors.grey,
                                    BlendMode.saturation,
                                  )
                                : const ColorFilter.mode(
                                    Colors.transparent,
                                    BlendMode.multiply,
                                  ),
                            child: QrImageView(
                              data: voucher.qrCode,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // QR Code Text
                        Text(
                          voucher.qrCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: canUse ? Colors.grey[600] : Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canUse 
                              ? 'Tunjukkan QR code ini ke merchant'
                              : 'QR code tidak dapat digunakan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: canUse ? Colors.grey[700] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Voucher Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Voucher Image
                        if (voucher.voucherImageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ColorFiltered(
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
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Voucher Name
                        Text(
                          voucher.voucherName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: canUse 
                                ? const Color(0xFF3F5135)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Merchant
                        if (voucher.merchantName.isNotEmpty)
                          Text(
                            voucher.merchantName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Discount Amount
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: canUse
                                  ? [const Color(0xFFB3CC86), const Color(0xFF798E5E)]
                                  : [Colors.grey[400]!, Colors.grey[600]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Potongan Harga',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Rp. ${voucher.discountAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Divider
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        
                        // Status Info
                        _buildInfoRow(
                          icon: Icons.monetization_on,
                          label: 'Koin Terpakai',
                          value: '${voucher.coinsSpent} koin',
                          iconColor: const Color(0xFFFFD700),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Tanggal Tukar',
                          value: _formatDate(voucher.purchasedAt),
                          iconColor: const Color(0xFF798E5E),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.access_time,
                          label: 'Berlaku Hingga',
                          value: _formatDate(voucher.validUntil),
                          iconColor: isExpired ? Colors.red : const Color(0xFF798E5E),
                        ),
                        if (voucher.used && voucher.usedAt != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.check_circle,
                            label: 'Digunakan Pada',
                            value: _formatDate(voucher.usedAt!),
                            iconColor: Colors.grey,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      color: const Color(0xFFF5F5F5),
      child: const Icon(
        Icons.card_giftcard,
        color: Color(0xFFB3CC86),
        size: 60,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3F5135),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
