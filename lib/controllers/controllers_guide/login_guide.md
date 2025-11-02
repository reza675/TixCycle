# PANDUAN PENGGUNAAN LOGIN CONTROLLER (untuk halaman login)

## Instalasi
    - extends class view (login page) ke GetView<LoginController>
    - contoh penggunaan (beserta key & form):
        import 'package:flutter/material.dart';
        import 'package:get/get.dart';
        import 'package:tixcycle/controllers/login_controller.dart';
        import 'package:tixcycle/routes/app_routes.dart'; // Impor rute

        // 1. Gunakan 'GetView<LoginController>'
        class LoginPage extends GetView<LoginController> {
        const LoginPage({Key? key}) : super(key: key);

        @override
        Widget build(BuildContext context) {
            return Scaffold(
            appBar: AppBar(title: const Text("Login")),
            body: Center(
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                // 2. Gunakan widget Form dan hubungkan 'key'-nya
                child: Form(
                    key: controller.formKey, // Hubungkan GlobalKey
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 32),
                        _buildLoginButton(),
                        _buildRegisterButton(), // Tombol untuk pindah ke halaman registrasi
                    ],
                    ),
                ),
                ),
            ),
            );
        }

        // ... (lihat implementasi widget di bawah)
        }

## Hubungkan form input

    - hubungkan TextFormField ke TextEditingController yang ada di LoginController
    - pisahkan tiap kolom input sebagai widget buatan (opsional tapi lebih baik)
### contoh bagian Email
    Widget _buildEmailField() {
    return TextFormField(
        // 1. Hubungkan controller
        controller: controller.emailController,
        decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
        // 2. Tambahkan validasi
        validator: (value) {
        if (value == null || value.isEmpty) {
            return 'Email tidak boleh kosong';
        }
        if (!GetUtils.isEmail(value)) {
            return 'Format email tidak valid';
        }
        return null;
        },
    );
    }
### contoh bagian password
nb: pakai obx di bagian logo mata (tombol visibilitas password)
    Widget _buildPasswordField() {
        // 1. Bungkus dengan Obx agar ikon mata berfungsi
        return Obx(() => TextFormField(
                // 2. Hubungkan controller
                controller: controller.passwordController,
                // 3. Gunakan state 'isPasswordVisible'
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                // 4. Buat tombol ikon mata
                suffixIcon: IconButton(
                    icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    ),
                    // 5. Panggil metode controller
                    onPressed: controller.togglePasswordVisibility,
                ),
                ),
                // 6. Tambahkan validasi
                validator: (value) {
                if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                }
                return null;
                },
            ));
        }
## hubungkan tombol aksi/submit
    - hubungkan tombol login ke method signInWithEmailPassword, (isi di parameter onpressed)
    - gunakan state isLoading untuk menampilkan circularProgressIndicator (ikon muter2)
### contoh tombol login
    Widget _buildLoginButton() {
        // Bungkus dengan Obx untuk menampilkan loading
        return Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                // 1. Panggil metode controller saat ditekan
                onPressed: controller.isLoading.value
                    ? null // Nonaktifkan tombol saat loading
                    : controller.signInWithEmailPassword,
                child: controller.isLoading.value
                    // 2. Tampilkan loading indicator jika 'isLoading' true
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                        ),
                    )
                    // 3. Tampilkan teks jika 'isLoading' false
                    : const Text("LOGIN"),
            ));
        }
### contoh tombol pindah ke halaman register
    Widget _buildRegisterButton() {
        return TextButton(
            child: const Text("Belum punya akun? Daftar di sini"),
            onPressed: () {
            // Panggil rute yang sudah Anda daftarkan di AppPages
            Get.toNamed(AppRoutes.REGISTER);
            },
        );
        }