import 'package:flutter/material.dart';
import 'package:tixcycle/views/lihat_tiket.dart';
import 'views/beranda.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
