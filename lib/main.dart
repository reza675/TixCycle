import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/views/beli_tiket.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tixcycle/views/beranda.dart';
import 'package:tixcycle/views/pencarian_tiket.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TixCycle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xFF3F5135))),
      home: const BerandaPage(),
    );
  }
}
