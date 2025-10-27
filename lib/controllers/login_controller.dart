import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/repositories/auth_repository.dart';
import 'package:tixcycle/routes/app_routes.dart';

class LoginController extends GetxController{
  
  final AuthRepository _authRepository;

  LoginController(this._authRepository);

  final _formKey = GlobalKey<FormState>();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();


  Future<void> signInWithEmailPassword() async{
    
    if(_formKey.currentState?.validate() ?? false){
      isLoading(true);
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      try{
        await _authRepository.signIn(email, password);
        Get.offAllNamed(AppRoutes.BERANDA);
      } on FirebaseAuthException catch (e){
        Get.snackbar("Login Gagal", 
        _getFirebaseAuthErrorMessage(e.code), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white,
        );
      
      } catch (e){
        Get.snackbar("Login Gagal", 
        "Silahkan coba lagi", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white,
        );
        
      } finally{
        isLoading(false);
      }
    }
    
  }


  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan otentikasi.';
    }
  }

  void changePAsswordVisibility(){    // pakai di tombol mata (password visible/invisible)
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose(){
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}