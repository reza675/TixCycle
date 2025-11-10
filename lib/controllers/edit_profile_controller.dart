import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/repositories/user_repository.dart';

class EditProfileController extends GetxController {
  final UserRepository _userRepository;
  final UserAccountController _userAccountController;

  EditProfileController(this._userRepository, this._userAccountController);

  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;
  var isAdmin = false.obs;

  // Controller untuk Info Pribadi
  late TextEditingController nameController;
  late TextEditingController provinceController;
  late TextEditingController birthDateController;
  late TextEditingController occupationController; 
  late TextEditingController cityController;
  late TextEditingController genderController;
  //info akun
  late TextEditingController idTypeController;
  late TextEditingController idNumberController;
  late TextEditingController phoneController;


  @override
  void onInit() {
    super.onInit();
    final user = _userAccountController.userProfile.value;
    if (user != null && user.email == "tixcycleproject@gmail.com") {
      isAdmin.value = true;
    }
    // Info Pribadi
    nameController = TextEditingController(text: user?.displayName ?? '');
    provinceController = TextEditingController(text: user?.province ?? '');
    occupationController = TextEditingController(text: user?.occupation ?? 'Belum diatur'); 
    cityController = TextEditingController(text: user?.city ?? 'Belum diatur'); 
    genderController = TextEditingController(text: user?.gender ?? 'Belum diatur'); 

    String formattedDate = "";
    if (user?.birthOfDate != null) {
      formattedDate = DateFormat('dd/MM/yyyy').format(user!.birthOfDate!.toDate());
    }
    birthDateController = TextEditingController(text: formattedDate);

    idTypeController = TextEditingController(text: user?.idType ?? 'Belum diatur');
    idNumberController = TextEditingController(text: user?.idNumber ?? 'Belum diatur');
    String fullPhoneNumber = user?.phoneNumber ?? '';
    String phoneWithoutPrefix = fullPhoneNumber;
    if (fullPhoneNumber.startsWith('+62')) {
      phoneWithoutPrefix = fullPhoneNumber.substring(3); 
    } else if (fullPhoneNumber.startsWith('0')) {
      phoneWithoutPrefix = fullPhoneNumber.substring(1); 
    }
    phoneController = TextEditingController(text: phoneWithoutPrefix);
  }

  Future<void> saveProfile() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading(true);
        final user = _userAccountController.userProfile.value;
        if (user == null) throw Exception("User not found");
        Timestamp? birthOfDateTimestamp;
        try {
          final birthDate = DateFormat('dd/MM/yyyy')
              .parseStrict(birthDateController.text.trim());
          birthOfDateTimestamp = Timestamp.fromDate(birthDate);
        } catch (e) {
          // Abaikan jika format salah
        }
        final String phoneNumber =
            "+62${phoneController.text.trim().replaceAll(RegExp(r'^[0]'), '')}";

        final Map<String, dynamic> updatedData = {
          // Info Pribadi
          'displayName': nameController.text.trim(),
          'province': provinceController.text.trim(),
          'birthOfDate': birthOfDateTimestamp,
          'occupation': occupationController.text.trim(),
          'city': cityController.text.trim(),
          'gender': genderController.text.trim(),
          'idType': idTypeController.text.trim(),
          'idNumber': idNumberController.text.trim(),
          'phoneNumber': phoneNumber,
        };

        await _userRepository.updateProfilUser(user.id, updatedData);

        await _userAccountController.refreshUserProfile();

        isLoading(false);
        Get.back(); 
        Get.snackbar(
          "Berhasil",
          "Profil berhasil diperbarui.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        isLoading(false);
        Get.snackbar(
          "Gagal",
          "Terjadi kesalahan: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    provinceController.dispose();
    birthDateController.dispose();
    occupationController.dispose();
    cityController.dispose();
    genderController.dispose();
    idTypeController.dispose();
    idNumberController.dispose();
    phoneController.dispose();
    
    super.onClose();
  }
}