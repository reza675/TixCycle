import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart';
import 'package:tixcycle/controllers/pembayaran_tiket_controller.dart';
import 'package:tixcycle/models/cart_item_model.dart';
import 'package:tixcycle/models/payment_method_model.dart';
import 'package:tixcycle/routes/app_routes.dart';

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
        body: Obx(() {
          switch (controller.currentStep.value) {
            case 1:
              return _buildStep1DetailPemesan(context);
            case 2:
              return _buildStep2PilihMetode(context);
            case 3:
              return _buildStep3Bayar(context); 
            case 4:
              return _buildStep4Selesai(context); 
            default:
              return const Center(child: Text('Halaman tidak ditemukan'));
          }
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: c4),
        onPressed: () {
          final step = controller.currentStep.value;   
          if (step == 4) { 
            Get.offAllNamed(AppRoutes.BERANDA);
          } 
          else if (step > 1) {
            controller.currentStep.value = step - 1; 
          } 
          else { 
            Get.back(); 
          }
        },
      ),
      title: Obx(() {
        String title;
        switch (controller.currentStep.value) {
          case 2:
            title = 'Pilih Metode';
            break;
          case 3:
            title = 'Payment'; 
            break;
          case 4:
            title = 'Selesai';
            break;
          default:
            title = 'Pembayaran';
        }
        return Text(
          title,
          style: const TextStyle(
            color: c4,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        );
      }),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Obx(() {
          if (controller.currentStep.value > 1) {
            return _buildStepper(controller.currentStep.value);
          } else {
            return const SizedBox.shrink(); 
          }
        }),
      ),
    );
  }

  Widget _buildStepper(int activeStep) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: c1.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c3, width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStepperItem("Pilih Metode", 1, activeStep == 2),
          _buildStepperItem("Bayar", 2, activeStep == 3),
          _buildStepperItem("Selesai", 3, activeStep == 4),
        ],
      ),
    );
  }

  Widget _buildStepperItem(String title, int step, bool isActive) {
    final color = isActive ? c4 : Colors.grey[700];
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isActive ? c4 : Colors.grey[400],
            child: Text(
              '$step',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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

  // detail pesanan
  Widget _buildStep1DetailPemesan(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _buildCardContainer(_buildDetailPembelianWidget()),
            const SizedBox(height: 24),
            _buildCardContainer(_buildDetailPemesanWidget()),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildLanjutkanButton(
                text: "Lanjutkan",
                onPressed: controller.goToStep2,
                isLoading: false.obs,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPembelianWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Pembelian',
          style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c4),
        ),
        const Divider(color: c3, thickness: 1, height: 24),
        ...controller.cartItems.map((item) => _buildPurchaseItem(item)),
        const Divider(color: c3, thickness: 1, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total :',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: c4)),
            Obx(() => Text(
                'Rp${controller.totalPrice.value.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: c4))),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchaseItem(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text('${item.ticket.categoryName} (${item.quantity.value}x)',
                style: const TextStyle(fontSize: 15, color: c4),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 16),
          Text('Rp${item.subtotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 15, color: c4)),
        ],
      ),
    );
  }

  Widget _buildDetailPemesanWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detail Pemesan',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: c4)),
        const SizedBox(height: 20),
        _buildTextFormField(
          label: 'Nama',
          controller: controller.nameController,
          icon: Icons.person_outline,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Nama tidak boleh kosong'
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          label: 'Email',
          controller: controller.emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Email tidak boleh kosong';
            if (!GetUtils.isEmail(value)) return 'Format email tidak valid';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPhoneFormField(
          label: 'Nomor Telepon',
          controller: controller.phoneController,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Nomor telepon tidak boleh kosong'
              : null,
        ),
      ],
    );
  }

  Widget _buildTextFormField(
      {required String label,
      required TextEditingController controller,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black87),
          decoration: _buildInputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[600])),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPhoneFormField(
      {required String label,
      required TextEditingController controller,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.black87),
          decoration: _buildInputDecoration(
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 4),
                Text('(+62)',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({Widget? prefixIcon}) {
    return InputDecoration(
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: c3, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2)));
  }

  // pilih metode
  Widget _buildStep2PilihMetode(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final Map<String, List<PaymentMethodModel>> groupedMethods = {};
      for (var method in controller.paymentMethods) {
        (groupedMethods[method.category] ??= []).add(method);
      }
      final categories = groupedMethods.keys.toList();
      categories.sort((a, b) {
        if (a == 'Transfer Bank') return -1;
        if (b == 'Transfer Bank') return 1;
        if (a == 'E-Wallet') return -1;
        if (b == 'E-Wallet') return 1;
        return a.compareTo(b);
      });

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            ...categories.map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildCardContainer(_buildPaymentCategoryWidget(
                      category, groupedMethods[category]!)),
                )),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildLanjutkanButton(
                text: "Lanjutkan",
                onPressed: controller.selectedMethod.value == null
                    ? null
                    : controller.prepareFinalOrder, 
                isLoading: false.obs,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentCategoryWidget(
      String categoryName, List<PaymentMethodModel> methods) {
    bool showLihatSemua = false;
    List<PaymentMethodModel> displayMethods = methods;
    String title = categoryName;

    if (categoryName == "Transfer Bank") {
      title = "Transfer Bank (Virtual Account)";
      if (methods.length > 3) {
        displayMethods = methods.take(3).toList();
        showLihatSemua = true;
      }
    } else if (categoryName == "E-Wallet") {
      if (methods.length > 4) {
        displayMethods = methods.take(4).toList();
        showLihatSemua = true;
      }
    } else if (categoryName == "Gerai Retail") {
      if (methods.length > 2) {
        displayMethods = methods.take(2).toList();
        showLihatSemua = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: c4)),
        const SizedBox(height: 16),
        if (categoryName == "E-Wallet" || categoryName == "Gerai Retail")
          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: displayMethods.map((method) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: _buildGridItem(method),
                );
              }).toList(),
            ),
          )
        else
          ...displayMethods.map((method) => _buildPaymentMethodItem(method)),
        if (showLihatSemua) ...[
          const SizedBox(height: 16),
          Center(
              child: Text("Lihat Semua ⌄",
                  style: TextStyle(color: c3, fontWeight: FontWeight.w600))),
        ]
      ],
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethodModel method) {
    return Obx(() {
      final bool isSelected = controller.selectedMethod.value?.id == method.id;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: isSelected ? c2.withOpacity(0.3) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? c3 : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1)),
        child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onTap: () => controller.selectPaymentMethod(method),
            leading: Image.asset(method.logoUrl,
                width: 48,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.business_center, size: 30, color: c4)),
            title: Text(method.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: c4, fontSize: 15)),
            trailing: Radio<String?>(
                value: method.id,
                groupValue: controller.selectedMethod.value?.id,
                onChanged: (String? value) =>
                    controller.selectPaymentMethod(method),
                activeColor: c3)),
      );
    });
  }

  Widget _buildGridItem(PaymentMethodModel method) {
    return Obx(() {
      final bool isSelected = controller.selectedMethod.value?.id == method.id;
      return GestureDetector(
        onTap: () => controller.selectPaymentMethod(method),
        child: Container(
            width: 130,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: isSelected ? c2.withOpacity(0.3) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected ? c3 : Colors.grey[300]!,
                    width: isSelected ? 2 : 1)),
            child: Image.asset(method.logoUrl,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    Text(method.name, textAlign: TextAlign.center))),
      );
    });
  }

  Widget _buildStep3Bayar(BuildContext context) {
    return Obx(() {
      if (controller.finalOrder.value == null ||
          controller.selectedMethod.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final String category = controller.selectedMethod.value!.category;
      
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), 
              child: Text(
                category,
                style: const TextStyle(
                  color: c4,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      

            _buildCardContainer(
                _buildPaymentCodeWidget()), 
            const SizedBox(height: 24),
            _buildCardContainer(
                _buildPaymentInstructionsWidget()), 
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildLanjutkanButton(
                text: "Lanjutkan",
                onPressed: controller.saveOrderAndGoToStep4, 
                isLoading: controller.isLoading, 
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentCodeWidget() {
    final order = controller.finalOrder.value!;
    final method = controller.selectedMethod.value!;

    final String codeLabel =
        (method.category == "Gerai Retail") ? "Kode Bayar:" : "No. Rekening:";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(method.logoUrl,
                width: 48,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.business_center, size: 30, color: c4)),
            const SizedBox(width: 12),
            Text(method.name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: c4)),
          ],
        ),
        const Divider(color: c3, thickness: 1, height: 24),
        Text(codeLabel, style: const TextStyle(fontSize: 15, color: c4)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                order.paymentCode,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: c4,
                    letterSpacing: 1.2),
              ),
            ),
            TextButton(
              child: const Text("SALIN",
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.paymentCode));
                Get.snackbar("Tersalin", "Kode pembayaran berhasil disalin.",
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.lightGreen,
                    colorText: Colors.white);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Bayar pesanan ke Virtual Account di atas sebelum membuat pesanan kembali dengan Virtual Account agar nomor tetap sama.",
          style:
              TextStyle(fontSize: 13, color: c4.withOpacity(0.8), height: 1.4),
        ),
        const SizedBox(height: 8),
        Text(
          "Hanya menerima dari Bank Mandiri", // Ini statis di desain Anda
          style: TextStyle(
              fontSize: 13,
              color: c4.withOpacity(0.8),
              height: 1.4,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPaymentInstructionsWidget() {
    final method = controller.selectedMethod.value!;
    final title = (method.category == "Gerai Retail")
        ? "Pembayaran via ${method.name}"
        : "Petunjuk Transfer via ${method.name}";

    return ExpansionTile(
      title: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: c4)),
      tilePadding: EdgeInsets.zero,
      childrenPadding:
          const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
      children: [
        Text(
          method.paymentInstructions,
          style:
              TextStyle(color: c4.withOpacity(0.9), height: 1.6, fontSize: 14),
        ),
      ],
    );
  }

  // --- STEP 4: SELESAI ---

  Widget _buildStep4Selesai(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: _buildCardContainer(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: c3, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Pembayaran Diproses',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: c4),
            ),
            const SizedBox(height: 12),
            Text(
              'Pesanan Anda sedang menunggu konfirmasi pembayaran. Cek halaman "Transaksi" untuk melihat status pesanan Anda.',
              style: TextStyle(
                  fontSize: 15, color: c4.withOpacity(0.8), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildLanjutkanButton(
              text: "Kembali ke Beranda",
              onPressed: () => Get.offAllNamed(AppRoutes.BERANDA),
              isLoading: false.obs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanjutkanButton(
      {required String text,
      VoidCallback? onPressed,
      required RxBool isLoading}) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: c4,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[400]),
            onPressed: onPressed,
            child: isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(text,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ));
  }
}
