import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/admin_voucher_controller.dart';
import 'package:tixcycle/models/voucher_model.dart';

class AdminVoucherModal extends StatefulWidget {
  final VoucherModel? voucherToEdit;

  const AdminVoucherModal({super.key, this.voucherToEdit});

  @override
  State<AdminVoucherModal> createState() => _AdminVoucherModalState();
}

class _AdminVoucherModalState extends State<AdminVoucherModal> {
  final controller = Get.find<AdminVoucherController>();
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController discountController;
  late TextEditingController stockController;
  late TextEditingController merchantController;

  String selectedCategory = 'Makanan & Minuman';
  final List<String> categories = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Lainnya',
  ];

  List<TextEditingController> tataCaraControllers = [];
  DateTime? validUntil;

  @override
  void initState() {
    super.initState();
    final voucher = widget.voucherToEdit;

    nameController = TextEditingController(text: voucher?.name ?? '');
    descController = TextEditingController(text: voucher?.description ?? '');
    priceController = TextEditingController(
      text: voucher?.priceCoins.toString() ?? '',
    );
    discountController = TextEditingController(
      text: voucher?.discountAmount.toString() ?? '',
    );
    stockController = TextEditingController(
      text: voucher?.stock.toString() ?? '',
    );
    merchantController =
        TextEditingController(text: voucher?.merchantName ?? '');

    selectedCategory = voucher?.category ?? categories[0];
    validUntil = voucher?.validUntil;

    if (voucher != null && voucher.tataCara.isNotEmpty) {
      for (var step in voucher.tataCara) {
        tataCaraControllers.add(TextEditingController(text: step));
      }
    } else {
      tataCaraControllers.add(TextEditingController());
    }

    if (voucher != null) {
      controller.existingImageUrl.value = voucher.imageUrl;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    discountController.dispose();
    stockController.dispose();
    merchantController.dispose();
    for (var ctrl in tataCaraControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucherToEdit != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB3CC86), Color(0xFF798E5E)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Voucher' : 'Tambah Voucher Baru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Image Picker
                    _buildImagePicker(),
                    const SizedBox(height: 20),

                    // Name
                    _buildTextField(
                      controller: nameController,
                      label: 'Nama Voucher',
                      icon: Icons.label,
                      validator: (val) => val?.isEmpty ?? true
                          ? 'Nama voucher harus diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: descController,
                      label: 'Deskripsi',
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Deskripsi harus diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Merchant
                    _buildTextField(
                      controller: merchantController,
                      label: 'Nama Merchant',
                      icon: Icons.store,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category,
                            color: Color(0xFF798E5E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price & Discount Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: priceController,
                            label: 'Harga (Koin)',
                            icon: Icons.monetization_on,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val?.isEmpty ?? true) return 'Harus diisi';
                              if (int.tryParse(val!) == null)
                                return 'Harus angka';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: discountController,
                            label: 'Potongan (Rp)',
                            icon: Icons.discount,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val?.isEmpty ?? true) return 'Harus diisi';
                              if (double.tryParse(val!) == null)
                                return 'Harus angka';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    _buildTextField(
                      controller: stockController,
                      label: 'Stok',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val?.isEmpty ?? true) return 'Stok harus diisi';
                        if (int.tryParse(val!) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Valid Until
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Berlaku Hingga',
                          prefixIcon: const Icon(Icons.calendar_today,
                              color: Color(0xFF798E5E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Text(
                          validUntil != null
                              ? _formatDate(validUntil!)
                              : 'Pilih tanggal kedaluwarsa',
                          style: TextStyle(
                            color: validUntil != null
                                ? const Color(0xFF3F5135)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tata Cara Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tata Cara Penukaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F5135),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Color(0xFF4CAF50)),
                          onPressed: () {
                            setState(() {
                              tataCaraControllers.add(TextEditingController());
                            });
                          },
                          tooltip: 'Tambah Langkah',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...tataCaraControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ctrl = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB3CC86),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: ctrl,
                                decoration: InputDecoration(
                                  hintText: 'Langkah ${index + 1}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (tataCaraControllers.length > 1)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    ctrl.dispose();
                                    tataCaraControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF3F5135),
                                  side: const BorderSide(
                                      color: Color(0xFF798E5E)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => _simpanVoucher(isEdit),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB3CC86),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        isEdit ? 'Update' : 'Simpan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(() {
      final hasImage = controller.selectedImage.value != null ||
          controller.existingImageUrl.value.isNotEmpty;

      return GestureDetector(
        onTap: controller.pilihGambar,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB3CC86).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: hasImage
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: controller.selectedImage.value != null
                          ? Image.file(
                              File(controller.selectedImage.value!.path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              controller.existingImageUrl.value,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: controller.pilihGambar,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pilih Gambar Voucher',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF798E5E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: validUntil ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB3CC86),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF3F5135),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        validUntil = picked;
      });
    }
  }

  Future<void> _simpanVoucher(bool isEdit) async {
    print("=== MODAL: SIMPAN BUTTON CLICKED ===");
    if (!formKey.currentState!.validate()) {
      print("=== MODAL: FORM VALIDATION FAILED ===");
      return;
    }

    final tataCara = tataCaraControllers
        .map((ctrl) => ctrl.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    print("=== MODAL: SETTING CONTROLLER DATA ===");
    // Set controller properties dengan data dari form
    controller.nameC.text = nameController.text.trim();
    controller.descriptionC.text = descController.text.trim();
    controller.priceCoinsC.text = priceController.text.trim();
    controller.discountAmountC.text = discountController.text.trim();
    controller.stockC.text = stockController.text.trim();
    controller.merchantNameC.text = merchantController.text.trim();
    controller.categoryC.text = selectedCategory;
    controller.validUntil.value = validUntil;
    
    // Set tata cara
    controller.tataCara.clear();
    for (var step in tataCara) {
      controller.tataCara.add(TextEditingController(text: step));
    }

    // Set mode edit dan existing image jika edit mode
    if (isEdit) {
      controller.isEditMode.value = true;
      controller.editingVoucherId.value = widget.voucherToEdit!.id;
      controller.existingImageUrl.value = widget.voucherToEdit!.imageUrl;
      print("=== MODAL: EDIT MODE ===");
    } else {
      controller.isEditMode.value = false;
      controller.editingVoucherId.value = '';
      print("=== MODAL: CREATE MODE ===");
    }

    print("=== MODAL: CALLING CONTROLLER.SIMPANVOUCHER() ===");
    // Panggil simpanVoucher dari controller
    await controller.simpanVoucher();
    print("=== MODAL: CONTROLLER.SIMPANVOUCHER() COMPLETED ===");
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
