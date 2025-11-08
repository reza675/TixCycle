import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/pembayaran_tiket_controller.dart';
import 'package:tixcycle/models/cart_item_model.dart';

class PembayaranTiket extends GetView<PembayaranTiketController> {
  const PembayaranTiket({super.key});

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
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDetailPembelian(context),
              const SizedBox(height: 24),
              _buildDetailPemesan(context),
              const SizedBox(height: 32),
              _buildLanjutkanButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: c4),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Pembayaran',
        style: TextStyle(
          color: c4,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildCardContainer(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: c1.withOpacity(0.95), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c3, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailPembelian(BuildContext context) {
    return _buildCardContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pembelian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: c4,
            ),
          ),
          const Divider(color: c3, thickness: 1, height: 24),
          
          ...controller.cartItems.map((item) => _buildPurchaseItem(item)),
          
          const Divider(color: c3, thickness: 1, height: 24),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: c4,
                ),
              ),
              Obx(() => Text(
                    'Rp${controller.totalPrice.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: c4,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseItem(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${item.ticket.categoryName} (${item.quantity.value}x)',
            style: const TextStyle(fontSize: 15, color: c4),
          ),
          Text(
            'Rp${item.subtotal.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 15, color: c4),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPemesan(BuildContext context) {
    return _buildCardContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pemesan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: c4,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildTextFormField(
            label: 'Nama',
            controller: controller.nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          
          _buildTextFormField(
            label: 'Email',
            controller: controller.emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          _buildPhoneFormField(
            label: 'Nomor Telepon',
            controller: controller.phoneController,
          ),
          
         
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black87),
          decoration: _buildInputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneFormField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.black87),
          decoration: _buildInputDecoration(
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tampilan bendera & (+62) seperti di gambar
                  const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 4),
                  Text(
                    '(+62)',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({Widget? prefixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: c3, width: 2),
      ),
    );
  }

  Widget _buildLanjutkanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: c4, 
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: controller.lanjutkanPembayaran,
        child: const Text(
          "Lanjutkan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}