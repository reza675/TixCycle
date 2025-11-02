# PANDUAN PENGGUNAAN REGISTER CONTROLLER (untuk halaman registrasi)

## Instalasi
     - extends class view (register page) ke GetView<RegisterController>
     - contoh penggunaan (beserta key & form):
        import 'package:flutter/material.dart';
        import 'package:get/get.dart';
        import 'package:tixcycle/controllers/register_controller.dart';
        import 'package:tixcycle/routes/app_routes.dart'; // Impor rute

        // 1. Gunakan GetView<RegisterController>
        class RegisterPage extends GetView<RegisterController> {
        const RegisterPage({Key? key}) : super(key: key);

        @override
        Widget build(BuildContext context) {
            return Scaffold(
            appBar: AppBar(title: const Text("Daftar Akun Baru")),
            body: Center(
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                // 2. Gunakan widget Form dan hubungkan 'key'-nya
                child: Form(
                    key: controller.formkey, // Hubungkan GlobalKey
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        _buildUsernameField(),
                        const SizedBox(height: 16),
                        _buildDisplayNameField(),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 16),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 32),
                        _buildRegisterButton(),
                        _buildLoginButton(), // Tombol untuk pindah ke halaman login
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

    - hubungkan TextFormField ke TextEditingController yang ada di RegisterController
    - pisahkan tiap kolom input sebagai widget buatan (opsional tapi lebih baik)

### contoh bagian Username

    Widget _buildUsernameField() {
    return TextFormField(
        // 1. Hubungkan controller
        controller: controller.usernameController,
        decoration: const InputDecoration(
        labelText: "Username",
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
        ),
        // 2. Tambahkan validasi
        validator: (value) {
        if (value == null || value.isEmpty) {
            return 'Username tidak boleh kosong';
        }
        return null;
        },
    );
    }

### contoh bagian Display Name

    Widget _buildDisplayNameField() {
    return TextFormField(
        controller: controller.displayNameController,
        decoration: const InputDecoration(
        labelText: "Nama Tampilan",
        prefixIcon: Icon(Icons.badge_outlined),
        border: OutlineInputBorder(),
        ),
        validator: (value) {
        if (value == null || value.isEmpty) {
            return 'Nama Tampilan tidak boleh kosong';
        }
        return null;
        },
    );
    }

### contoh bagian Email

    Widget _buildEmailField() {
    return TextFormField(
        controller: controller.emailController,
        decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
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

### contoh bagian Konfirmasi Password

    Widget _buildConfirmPasswordField() {
        return Obx(() => TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                labelText: "Konfirmasi Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                ),
                validator: (value) {
                if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                }
                // Validasi kesamaan password
                if (value != controller.passwordController.text) {
                    return 'Password tidak cocok';
                }
                return null;
                },
            ));
        }

## hubungkan tombol aksi/submit

    - hubungkan tombol "Daftar" ke method registerWithEmailPassword, (isi di parameter onPressed)
    - gunakan state isLoading untuk menampilkan CircularProgressIndicator (ikon muter2)

### contoh tombol Daftar

    Widget _buildRegisterButton() {
        // Bungkus dengan Obx untuk menampilkan loading
        return Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                // 1. Panggil metode controller saat ditekan
                onPressed: controller.isLoading.value
                    ? null // Nonaktifkan tombol saat loading
                    : controller.registerWithEmailPassword,
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
                    : const Text("DAFTAR"),
            ));
        }

### contoh tombol pindah ke halaman Login

    Widget _buildLoginButton() {
        return TextButton(
            child: const Text("Sudah punya akun? Login di sini"),
            onPressed: () {
            // Panggil rute yang sudah Anda daftarkan di AppPages
            Get.toNamed(AppRoutes.LOGIN);
            },
        );
        }