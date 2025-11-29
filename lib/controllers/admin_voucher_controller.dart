import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tixcycle/controllers/koin_controller.dart';
import 'package:tixcycle/models/voucher_model.dart';
import 'package:tixcycle/repositories/voucher_repository.dart';

class AdminVoucherController extends GetxController {
  final VoucherRepository repository;
  AdminVoucherController(this.repository);

  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final nameC = TextEditingController();
  final descriptionC = TextEditingController();
  final priceCoinsC = TextEditingController();
  final discountAmountC = TextEditingController();
  final categoryC = TextEditingController();
  final stockC = TextEditingController();
  final merchantNameC = TextEditingController();

  // Tata cara list
  var tataCara = <TextEditingController>[].obs;

  // Image
  var selectedImage = Rxn<File>();
  var existingImageUrl = ''.obs;

  // Loading & validation
  var isLoading = false.obs;
  var isEditMode = false.obs;
  var editingVoucherId = ''.obs;

  // Valid until date
  var validUntil = Rxn<DateTime>();

  @override
  void onClose() {
    nameC.dispose();
    descriptionC.dispose();
    priceCoinsC.dispose();
    discountAmountC.dispose();
    categoryC.dispose();
    stockC.dispose();
    merchantNameC.dispose();
    for (var controller in tataCara) {
      controller.dispose();
    }
    super.onClose();
  }

  void resetForm() {
    nameC.clear();
    descriptionC.clear();
    priceCoinsC.clear();
    discountAmountC.clear();
    categoryC.clear();
    stockC.clear();
    merchantNameC.clear();
    tataCara.clear();
    selectedImage.value = null;
    existingImageUrl.value = '';
    validUntil.value = null;
    isEditMode.value = false;
    editingVoucherId.value = '';
  }

  void addTataCaraField() {
    tataCara.add(TextEditingController());
  }

  void removeTataCaraField(int index) {
    tataCara[index].dispose();
    tataCara.removeAt(index);
  }

  Future<void> pilihGambar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: $e');
    }
  }

  Future<void> simpanVoucher() async {
    print("=== SIMPAN VOUCHER STARTED ===");
    print("Name: ${nameC.text}");
    print("Price: ${priceCoinsC.text}");
    print("Stock: ${stockC.text}");
    print("Is Edit Mode: ${isEditMode.value}");

    if (!_validateForm()) {
      print("=== VALIDATION FAILED ===");
      return;
    }

    try {
      isLoading(true);

      String imageUrl = existingImageUrl.value;
      print("=== Existing Image URL: $imageUrl ===");
      print("=== Selected Image: ${selectedImage.value?.path} ===");

      // Upload image jika ada image baru
      if (selectedImage.value != null) {
        print("=== UPLOADING IMAGE TO FIREBASE STORAGE ===");
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        final uploadedUrl = await repository.uploadVoucherImage(
          selectedImage.value!,
          isEditMode.value ? editingVoucherId.value : tempId,
        );

        print("=== UPLOAD RESULT: $uploadedUrl ===");
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
          print("=== IMAGE URL SET: $imageUrl ===");
          // Hapus image lama jika edit mode
          if (isEditMode.value && existingImageUrl.value.isNotEmpty) {
            await repository.deleteVoucherImage(existingImageUrl.value);
          }
        } else {
          print("=== IMAGE UPLOAD FAILED ===");
        }
      } else {
        print("=== NO IMAGE SELECTED ===");
      }

      final voucher = VoucherModel(
        id: '',
        name: nameC.text.trim(),
        description: descriptionC.text.trim(),
        priceCoins: int.parse(priceCoinsC.text),
        discountAmount: int.parse(discountAmountC.text),
        category: categoryC.text.trim(),
        imageUrl: imageUrl,
        stock: int.parse(stockC.text),
        merchantName: merchantNameC.text.trim(),
        tataCara: tataCara.map((c) => c.text.trim()).toList(),
        validUntil: validUntil.value,
        createdAt: DateTime.now(),
      );

      if (isEditMode.value) {
        await repository.updateVoucher(
            editingVoucherId.value, voucher.toJson());
        print("=== VOUCHER UPDATED ===");
        Get.snackbar('Berhasil', 'Voucher berhasil diperbarui');
      } else {
        await repository.createVoucher(voucher);
        print("=== VOUCHER CREATED ===");
        Get.snackbar('Berhasil', 'Voucher berhasil ditambahkan');
      }

      // Refresh KoinController untuk update voucher list
      try {
        print("=== REFRESHING KOIN CONTROLLER ===");
        final koinController = Get.find<KoinController>();
        await koinController.loadVouchers();
        print(
            "=== KOIN CONTROLLER REFRESHED, voucher count: ${koinController.voucherList.length} ===");
      } catch (e) {
        print("KoinController not found or error refreshing: $e");
      }

      print("=== CLOSING MODAL ===");
      Get.back();
      resetForm();
      print("=== SIMPAN VOUCHER COMPLETED ===");
    } catch (e) {
      print("=== ERROR SAVING VOUCHER: $e ===");
      Get.snackbar('Error', 'Gagal menyimpan voucher: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> hapusVoucher(VoucherModel voucher) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Yakin ingin menghapus voucher "${voucher.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await repository.deleteVoucher(voucher.id);
        Get.snackbar('Berhasil', 'Voucher berhasil dihapus');

        // Refresh KoinController untuk update voucher list
        try {
          final koinController = Get.find<KoinController>();
          await koinController.loadVouchers();
        } catch (e) {
          print("KoinController not found or error refreshing: $e");
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus voucher: $e');
    }
  }

  void loadVoucherForEdit(VoucherModel voucher) {
    isEditMode.value = true;
    editingVoucherId.value = voucher.id;

    nameC.text = voucher.name;
    descriptionC.text = voucher.description;
    priceCoinsC.text = voucher.priceCoins.toString();
    discountAmountC.text = voucher.discountAmount.toString();
    categoryC.text = voucher.category;
    stockC.text = voucher.stock.toString();
    merchantNameC.text = voucher.merchantName;
    existingImageUrl.value = voucher.imageUrl;
    validUntil.value = voucher.validUntil;

    tataCara.clear();
    for (var step in voucher.tataCara) {
      final controller = TextEditingController(text: step);
      tataCara.add(controller);
    }
  }

  bool _validateForm() {
    if (nameC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Nama voucher tidak boleh kosong');
      return false;
    }
    if (priceCoinsC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Harga coin tidak boleh kosong');
      return false;
    }
    if (discountAmountC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Jumlah diskon tidak boleh kosong');
      return false;
    }
    if (stockC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Stock tidak boleh kosong');
      return false;
    }
    if (merchantNameC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Nama merchant tidak boleh kosong');
      return false;
    }
    if (!isEditMode.value &&
        selectedImage.value == null &&
        existingImageUrl.value.isEmpty) {
      Get.snackbar('Error', 'Gambar voucher harus dipilih');
      return false;
    }
    return true;
  }
}
