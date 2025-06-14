import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'front_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: _getFirebaseOptions(),
  );
  runApp(const MyApp());
}

// Firebase configuration for different platforms
FirebaseOptions _getFirebaseOptions() {
  if (kIsWeb) {
    // Web configuration
    return const FirebaseOptions(
      apiKey: "AIzaSyAGGHbFAIAZSi6Rg3jSFKEAvKiGx5-Ul00",
      appId: "1:994798453240:web:your_web_app_id", // Replace with your actual web app ID
      messagingSenderId: "994798453240",
      projectId: "barangay-mercedes-mds",
      storageBucket: "barangay-mercedes-mds.firebasestorage.app",
      authDomain: "barangay-mercedes-mds.firebaseapp.com",
    );
  } else {
    // Mobile (Android/iOS) configuration
    return const FirebaseOptions(
      apiKey: "AIzaSyAGGHbFAIAZSi6Rg3jSFKEAvKiGx5-Ul00",
      appId: "1:994798453240:android:e837df9401ca738139960d",
      messagingSenderId: "994798453240",
      projectId: "barangay-mercedes-mds",
      storageBucket: "barangay-mercedes-mds.firebasestorage.app",
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Mercedes Document Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BarangayMercedesPage(),
    );
  }
}