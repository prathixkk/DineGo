import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nawaproject/constants.dart';
import 'package:nawaproject/screens/phoneLogin/number_verify_screen.dart';
import 'package:nawaproject/screens/home/home_screen.dart';
import 'package:nawaproject/screens/phoneLogin/phone_login_screen.dart';
import 'package:nawaproject/screens/qrScanner/qr_scanner_screen.dart';
import 'package:nawaproject/screens/signUp/components/sign_up_form.dart';
import 'package:nawaproject/screens/signUp/components/email_verification_screen.dart';
import 'package:nawaproject/screens/CartScreen/cart_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print("Firebase already initialized: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DineGo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: bodyTextColor),
          bodySmall: TextStyle(color: bodyTextColor),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.all(defaultPadding),
          hintStyle: TextStyle(color: bodyTextColor),
        ),
      ),

      // 👇 This decides what screen to show based on login state
      home: const AuthGate(),

      // Optional named routes if you're using pushNamed
      routes: {
        '/cart': (context) => const CartScreen(),
        '/phone': (context) => const MyPhone(),
        '/register': (context) => const SignUpForm(),
        '/verify': (context) => const NumberVerifyScreen(),
        '/qrScanner': (context) => QRScannerScreen(), // Add QR scanner route
        '/home': (context) => const HomeScreen(),
        '/verifyEmail': (context) => const EmailVerificationScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // Changed this to go to QR scanner instead of home
          return QRScannerScreen();
        } else {
          return const MyPhone(); // 🔐 Show login screen
        }
      },
    );
  }
}
