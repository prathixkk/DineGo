import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart'; // <- Add this line
import '../../components/welcome_text.dart';
import '../../constants.dart';

class NumberVerifyScreen extends StatefulWidget {
  const NumberVerifyScreen({super.key});

  @override
  State<NumberVerifyScreen> createState() => _NumberVerifyScreenState();
}

class _NumberVerifyScreenState extends State<NumberVerifyScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  void verifyOtp(String verificationId, String otp) async {
    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String phone = args['phone'];
    final String verificationId = args['verificationId'];

    return Scaffold(
      appBar: AppBar(title: const Text("Login to DineGo")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeText(
              title: "Verify phone number",
              text: "Enter the 6-digit code sent to $phone",
            ),
            const SizedBox(height: defaultPadding),
            Pinput(
              controller: otpController,
              length: 6,
              keyboardType: TextInputType.number,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 50,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor, width: 2),
                ),
              ),
              onCompleted: (pin) {
                verifyOtp(verificationId, pin);
              },
            ),
            const SizedBox(height: defaultPadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => verifyOtp(verificationId, otpController.text.trim()),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify"),
              ),
            ),
            const SizedBox(height: defaultPadding),
            const Center(
              child: Text(
                "By signing up you agree to our Terms\n& Privacy Policy.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
