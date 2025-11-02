import 'package:get/get.dart';
import 'package:tixcycle/repositories/auth_repository.dart';
import 'package:tixcycle/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tixcycle/models/user_model.dart';

class UserAccountController extends GetxController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  UserAccountController(this._authRepository, this._userRepository);

  // variabel reaktif
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authRepository.user);
    ever(firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) async {   // ketika status autentikasi berubah
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
      // Fitur login belum tersedia, jadi hanya tampilkan info
      Get.snackbar("Info",
          "Anda belum login. Fitur login akan tersedia di update berikutnya.");
      //Get.offAllNamed('/isi pake nama halaman login');
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
}
