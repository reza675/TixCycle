import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tixcycle/repositories/auth_repository.dart';
import 'package:tixcycle/routes/app_routes.dart';

class RegisterController extends GetxController{
  final AuthRepository _authRepository;
  RegisterController(this._authRepository);

  // form states
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  // ui states
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  Future<void> registerWithEmailPassword()async{
    if(formkey.currentState?.validate() ??false){
      if(passwordController.text.trim() != confirmPasswordController.text.trim()){
        Get.snackbar("Registrasi Gagal", "Pastikan password dan konfirmasi password cocok!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white,);
        return;
      }

      try {
        isLoading(true);
        await _authRepository.signUp(username: usernameController.text.trim(), password: passwordController.text.trim(), displayName: displayNameController.text.trim(), email: emailController.text.trim());

        Get.offNamed(AppRoutes.LOGIN);
        Get.snackbar(
          "Registrasi Berhasil", 
          "Akun anda berhasil dibuat. Silakan login.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

      } on FirebaseAuthException catch(e){
        Get.snackbar("Registrasi Gagal",
          _getFirebaseAuthErrorMessage(e.code),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      } catch (e){
        Get.snackbar(
          "Registrasi Gagal",
          "Terjadi kesalahan. Silakan coba lagi.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void togglePasswordVisibility(){
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String _getFirebaseAuthErrorMessage(String code){
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
  void onClose(){
    usernameController.dispose();
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
    
  }

}