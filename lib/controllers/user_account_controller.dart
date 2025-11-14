import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/repositories/auth_repository.dart';
import 'package:tixcycle/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tixcycle/services/supabase_storage_service.dart';

class UserAccountController extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final SupabaseStorageService _supabaseStorageService;

  UserAccountController(this._authRepository, this._userRepository,this._supabaseStorageService);

  // variabel reaktif
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  var isLoading = false.obs;

  // getter buat role
  bool get isAdmin => userProfile.value?.role == 'admin';
  bool get isUser => userProfile.value?.role == 'user';

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authRepository.user);
    ever(firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) async {
    // ketika status autentikasi berubah
    if (user != null) {
      try {
        isLoading(true);
        userProfile.value = await _userRepository.ambilProfilUser(user.uid);
      } catch (e) {
        Get.snackbar("Error", "Gagal  memuat profil pengguna: " + e.toString());
        userProfile.value = null;
      } finally {
        isLoading(false);
      }
    } else {
      userProfile.value = null;
    }
  }

  Future<void> refreshUserProfile() async {
    final user = firebaseUser.value;
    if (user != null) {
      try {
        isLoading(true);
        userProfile.value = await _userRepository.ambilProfilUser(user.uid);
      } catch (e) {
        Get.snackbar("Error", "Gagal memuat ulang profil: " + e.toString());
      } finally {
        isLoading(false);
      }
    }
  }

  Future<void> signOut() async {
    try {
      isLoading(true);
      await _authRepository.signOut();
    } catch (e) {
      Get.snackbar("Error", "Gagal sign out: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }
  Future<void> changeProfilePicture() async {
    final user = firebaseUser.value;
    if (user == null) {
      Get.snackbar("Gagal", "Anda harus login untuk mengubah foto.");
      return;
    }

    try {
      // Pilih gambar
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, 
      );

      if (image == null) return;
      
      File imageFile = File(image.path);

      isLoading(true);

      // Upload ke Supabase
      final String newImageUrl = await _supabaseStorageService.uploadProfileImage(
        imageFile, 
        user.uid, 
      );

      // Simpan URL baru ke Firestore
      await _userRepository.updateProfilUser(
        user.uid, 
        {'profileImageUrl': newImageUrl}
      );

      // Refresh data di UI
      await refreshUserProfile();
      
      isLoading(false);
      Get.snackbar(
        "Berhasil", 
        "Foto profil berhasil diperbarui!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      isLoading(false);
      Get.snackbar(
        "Gagal Upload", 
        "Terjadi kesalahan: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
