import 'package:flutter/material.dart';
import 'front_page.dart'; // Make sure this path is correct based on your project structure

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BarangayMercedesPage(), // Calls your BMDPSApp widget
    );
  }
}