import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/register_controller.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:intl/intl.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  static const Color c1_cream = Color(0xFFFFF8E2);
  static const Color c2_lightGreen = Color(0xFFB3CC86);
  static const Color c3_medGreen = Color(0xFF96AD72);
  static const Color c4_darkGreen = Color(0xFF3F5135);
  static const Color c5_lightCream = Color(0xFFECEDCB);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1_cream, c5_lightCream],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: controller.formkey,
                child: _buildRegisterCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCloseButton(),
          const SizedBox(height: 8),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildLogo(),
          const SizedBox(height: 24),
          _buildToggleButtons(isLoginView: false),
          const SizedBox(height: 24),
          _buildUsernameField(),
          const SizedBox(height: 16),
          _buildProvinceField(), 
          const SizedBox(height: 16),
          _buildBirthOfDateField(context),
          const SizedBox(height: 16),
          _buildPhoneField(), 
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          const SizedBox(height: 32),
          _buildRegisterButton(),
          const SizedBox(height: 16),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Username',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.usernameController,
          decoration: _buildInputDecoration(
            hint: 'e.g. jordanio123',
            icon: Icons.person_outline,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.emailController,
          decoration: _buildInputDecoration(
            hint: 'Jordan123@gmail.com',
            icon: Icons.email_outlined,
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
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
              decoration: _buildInputDecoration(
                hint: '********',
                icon: Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[500],
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            )),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Password',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
              controller: controller.confirmPasswordController,
              obscureText: !controller.isPasswordVisible.value,
              decoration: _buildInputDecoration(
                hint: '********',
                icon: Icons.lock_outline,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != controller.passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            )),
      ],
    );
  }
  Widget _buildProvinceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Province',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.provinceController,
          decoration: _buildInputDecoration(
            hint: 'e.g. Jakarta',
            icon: Icons.map_outlined,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Provinsi tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBirthOfDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Birth of date',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.birthOfDateController,
          readOnly: true,
          decoration: _buildInputDecoration(
            hint: '18/03/2000',
            icon: Icons.calendar_today_outlined,
          ).copyWith(
            suffixIcon: Icon(Icons.calendar_month_outlined,
                color: Colors.grey[500]),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('dd/MM/yyyy').format(pickedDate);
              controller.birthOfDateController.text = formattedDate;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal lahir tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          decoration: _buildInputDecoration(
            hint: '81234567890',
            icon: Icons.phone_outlined, 
          ).copyWith(
            prefixIcon: Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('(+62)',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                ],
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor telepon tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c3_medGreen, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: controller.isLoading.value
                ? null
                : controller.registerWithEmailPassword,
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Register",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ));
  }

  Widget _buildLoginButton() {
    return TextButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account? ",
              style: TextStyle(color: Colors.grey[600])),
          Text("Login",
              style:
                  TextStyle(color: c3_medGreen, fontWeight: FontWeight.bold)),
        ],
      ),
      onPressed: () {
        Get.offAllNamed(AppRoutes.LOGIN);
      },
    );
  }

  InputDecoration _buildInputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: c3_medGreen, width: 2),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () => Get.offAllNamed(AppRoutes.BERANDA),
        child: Icon(Icons.close, color: Colors.grey[600], size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Welcome to TixCycle',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: c4_darkGreen,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create an account or log in to explore about our app',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'images/LOGO.png',
      height: 100,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 100,
        width: 100,
        color: Colors.grey[200],
        child: Center(
            child:
                Text('Logo\n(images/LOGO.png)', textAlign: TextAlign.center)),
      ),
    );
  }

  Widget _buildToggleButtons({required bool isLoginView}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isLoginView) {
                  Get.offNamed(AppRoutes.LOGIN);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLoginView ? c2_lightGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLoginView ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isLoginView) {
                  Get.offNamed(AppRoutes.REGISTER);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isLoginView ? c2_lightGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isLoginView ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
