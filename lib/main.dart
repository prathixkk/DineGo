import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nawaproject/constants.dart';
import 'package:nawaproject/screens/phoneLogin/number_verify_screen.dart';
import 'package:nawaproject/screens/home/home_screen.dart';
import 'package:nawaproject/screens/phoneLogin/phone_login_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Flutter Way - Foodly UI Kit',
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

      // ✅ Define routes
      initialRoute: '/phone',
      routes: {
        '/phone': (context) => const MyPhone(), // phone login screen
        '/verify': (context) => const NumberVerifyScreen(), // otp screen
        '/home': (context) => const HomeScreen(), // home screen after login
      },
    );
  }
}
