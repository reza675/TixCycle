import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tixcycle/repositories/auth_repository.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/intl.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository;
  RegisterController(this._authRepository);

  // form states
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final provinceController = TextEditingController();
  final birthOfDateController = TextEditingController(); 
  final phoneController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  // ui states
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  Future<void> registerWithEmailPassword() async {
    if (formkey.currentState?.validate() ?? false) {
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Get.snackbar(
          "Registrasi Gagal",
          "Pastikan password dan konfirmasi password cocok!", 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Timestamp? birthOfDateTimestamp;
      try {
        // Parse tanggal dari format "dd/MM/yyyy"
        final birthDate = DateFormat('dd/MM/yyyy')
            .parseStrict(birthOfDateController.text.trim());
        birthOfDateTimestamp = Timestamp.fromDate(birthDate);
      } catch (e) {
        Get.snackbar(
          "Registrasi Gagal",
          "Format tanggal lahir tidak valid. Harap gunakan format dd/mm/yyyy.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Format nomor telepon dengan +62
      final String phoneNumber =
          "+62${phoneController.text.trim().replaceAll(RegExp(r'^[0]'), '')}";

      try {
        isLoading(true);
        await _authRepository.signUp(
            username: usernameController.text.trim(),
            password: passwordController.text.trim(),
            displayName: usernameController.text.trim(),
            email: emailController.text.trim(),
            province: provinceController.text.trim(),
            birthOfDate: birthOfDateTimestamp,
            phoneNumber: phoneNumber,
      );
        await _authRepository.signOut(); // jangan nyelonong login le
        Get.offNamed(AppRoutes.LOGIN);
        Get.snackbar(
          "Registrasi Berhasil",
          "Akun anda berhasil dibuat. Silakan login.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } on FirebaseAuthException catch (e) {
        Get.snackbar(
          "Registrasi Gagal",
          _getFirebaseAuthErrorMessage(e.code),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Registrasi Gagal",
          "Terjadi kesalahan. Silakan coba lagi.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading(false);
      }
    } else {
      isLoading(false);
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Email sudah terdaftar. Silakan gunakan email lain.";
      case 'invalid-email':
        return "Email tidak valid.";
      case 'operation-not-allowed':
        return "Operasi tidak diizinkan.";
      case 'weak-password':
        return "Password terlalu lemah.";
      default:
        return "Terjadi kesalahan autentikasi. Silakan coba lagi.";
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    provinceController.dispose();
    birthOfDateController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
