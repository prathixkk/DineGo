import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  bool isLoading = false;
  Map? arguments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing navigation data.")),
      );
    }
  }

  Future<void> checkVerification() async {
    setState(() => isLoading = true);

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    print("Email Verified: ${user?.emailVerified}");

    setState(() {
      isVerified = user?.emailVerified ?? false;
      isLoading = false;
    });

    if (isVerified && arguments != null) {
      final firestore = FirebaseFirestore.instance;
      final String phone = arguments!['phone'];
      final Map<String, dynamic> userData = Map<String, dynamic>.from(arguments!['userData']);
      userData['emailVerified'] = true;

      try {
        // Save user to 'users' collection
        await firestore.collection("users").doc(phone).set(userData);

        // Delete from 'pendingUsers'
        await firestore.collection("pendingUsers").doc(phone).delete();

        // Send OTP
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {
            debugPrint("Auto verification completed");
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint("Verification failed: ${e.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification failed: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            debugPrint("OTP sent to $phone");

            Navigator.pushReplacementNamed(
              context,
              '/verify',
              arguments: {
                'phone': phone,
                'verificationId': verificationId,
              },
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            debugPrint("Auto retrieval timeout");
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating user data: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not verified yet.")),
      );
    }
  }

  Future<void> resendEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "A verification link has been sent to your email address. Please verify it before proceeding.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : checkVerification,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("I’ve Verified My Email"),
            ),
            TextButton(
              onPressed: resendEmail,
              child: const Text("Resend Email"),
            ),
          ],
        ),
      ),
    );
  }
}
