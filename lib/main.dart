import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ✅ NEW
import 'package:fluttertoast/fluttertoast.dart'; // ✅ Optional for toasts

import 'package:nawaproject/constants.dart';
import 'package:nawaproject/screens/phoneLogin/number_verify_screen.dart';
import 'package:nawaproject/screens/home/home_screen.dart';
import 'package:nawaproject/screens/phoneLogin/phone_login_screen.dart';
import 'package:nawaproject/screens/qrScanner/qr_scanner_screen.dart';
import 'package:nawaproject/screens/signUp/components/sign_up_form.dart';
import 'package:nawaproject/screens/signUp/components/email_verification_screen.dart';
import 'package:nawaproject/screens/CartScreen/cart_screen.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Background message: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print("Firebase already initialized: $e");
  }

  // ✅ Set background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      // home: const AuthGate(),
      home: MyPhone(),
      routes: {
        '/cart': (context) => const CartScreen(),
        '/phone': (context) => const MyPhone(),
        '/register': (context) => const SignUpForm(),
        '/verify': (context) => const NumberVerifyScreen(),
        '/qrScanner': (context) => QRScannerScreen(),
        '/home': (context) => const HomeScreen(),
        '/verifyEmail': (context) => const EmailVerificationScreen(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _setupFCM(); // ✅ Initialize FCM setup
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions (iOS)
    await messaging.requestPermission();

    // Get FCM token
    String? token = await messaging.getToken();
    print("📱 FCM Token: $token");

    // Optional: Show notification/toast on login
    if (FirebaseAuth.instance.currentUser != null) {
      // This is triggered after login
      Future.delayed(const Duration(milliseconds: 500), () {
        Fluttertoast.showToast(
          msg: "🎉 Welcome! You just logged in.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    }

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📬 Foreground message: ${message.notification?.title}");
      if (message.notification != null) {
        Fluttertoast.showToast(
          msg:
              "🔔 ${message.notification!.title}: ${message.notification!.body}",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    });
  }

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
          return QRScannerScreen(); // Redirect to QR
        } else {
          return const MyPhone(); // Login page
        }
      },
    );
  }
}
