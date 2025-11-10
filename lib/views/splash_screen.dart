import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  static const Color c1_cream = Color(0xFFFFF8E2); 
  static const Color c4_darkGreen = Color(0xFF3F5135); 
  static const Color c3_medGreen = Color(0xFF798E5E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c1_cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              Image.asset(
                'images/LOGO.png', 
                width: 150,
                height: 150, 
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Logo tidak ditemukan'),
              ),
              const SizedBox(height: 48),

              Text(
                'Selamat Datang di TixCycle!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: c4_darkGreen,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Temukan dan pesan tiket event favoritmu dengan mudah dan ramah lingkungan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: c3_medGreen,
                  height: 1.5,
                ),
              ),
              
              const Spacer(flex: 3),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c4_darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.goToBeranda, 
                child: const Text(
                  "Lanjutkan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}