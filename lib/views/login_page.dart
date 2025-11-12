import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/login_controller.dart';
import 'package:tixcycle/routes/app_routes.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

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
                key: controller.formKey,
                child: _buildLoginCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
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
          _buildToggleButtons(isLoginView: true),
          const SizedBox(height: 24),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberMeRow(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildSocialLogin(),
          const SizedBox(height: 16),
          _buildRegisterButton(),
        ],
      ),
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
            hint: 'example@gmail.com',
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

  Widget _buildLoginButton() {
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
                : controller.signInWithEmailPassword,
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Log In",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ));
  }

  Widget _buildRegisterButton() {
    return TextButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account? ",
              style: TextStyle(color: Colors.grey[600])),
          Text("Sign Up",
              style:
                  TextStyle(color: c3_medGreen, fontWeight: FontWeight.bold)),
        ],
      ),
      onPressed: () {
        Get.offNamed(AppRoutes.REGISTER);
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
        onTap: () => Get.offAllNamed(
            AppRoutes.BERANDA), 
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
          color: Color(0xFF314417),
        ),
      ),
    ],
  );
}


 Widget _buildLogo() {
  return Container(
   
    child: Image.asset(
      'images/LOGO.png',
      height: 100,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 100,
        width: 100,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'Logo\n(images/LOGO.png)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
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

  Widget _buildRememberMeRow() {
    var rememberMe = false.obs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: rememberMe.value,
                    onChanged: (value) => rememberMe.value = value ?? false,
                    activeColor: c3_medGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Remember me', style: TextStyle(color: Colors.grey[700])),
              ],
            )),
        TextButton(
          onPressed: () {/* TODO: forgot password diapain ya */},
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: c3_medGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Or login with',
                  style: TextStyle(color: Colors.grey[600])),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           GestureDetector(
              onTap: controller.signInWithGoogle, 
              child: _buildSocialButton('images/social/google.png'),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildSocialButton(String? imagePath, {IconData? icon}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
        ],
      ),
      child: Center(
        child: imagePath != null
            ? Image.asset(
                imagePath,
                height: 28,
                width: 28,
                errorBuilder: (c, e, s) =>
                    Icon(Icons.error_outline, color: Colors.grey[400]),
              )
            : Icon(icon, color: Colors.grey[700], size: 28),
      ),
    );
  }
}
