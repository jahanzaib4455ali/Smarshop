import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core import wapas add kiya
import 'Admin Pannel/admin_Screen.dart';
import 'Screens/home_page.dart';
import 'Screens/login_page.dart';
import 'screens/splash_screen.dart'; // Ensure correct path to SplashScreen
import 'firebase_options.dart'; // FlutterFire CLI se generate hui file (zaroori)

void main() async { // main() function ko async banaya
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase ko sirf yahan par ek baar initialize kiya gaya hai.
  // Is try-catch block se app crash hone se bach jayegi agar koi ghalti ho.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase successfully initialized!");
  } catch (e) {
    // Agar initialization fail ho, toh hum sirf console mein error print kar denge.
    print("Firebase Initialization Failed: $e");
    // App phir bhi chalegi (lekin Firebase services kaam nahi karengi jab tak yeh theek na ho)
  }

  runApp(const MyEcommerceApp());
}

class MyEcommerceApp extends StatelessWidget {
  const MyEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // SplashScreen -> LoginPage
    );
  }
}