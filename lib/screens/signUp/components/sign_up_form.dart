import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController countryController = TextEditingController(text: "+91");

  String selectedGender = "Male";
  bool isLoading = false;

  final firestore = FirebaseFirestore.instance;

  void registerUser() async {
    // Validate inputs first
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text;
    String fullPhone = countryController.text + phone;

    // Print debug information
    debugPrint("Attempting to register with: $name, $email, $fullPhone");

    // Input validation
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      showError("Please fill in all fields");
      return;
    }
    
    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      showError("Please enter a valid 10-digit phone number");
      return;
    }
    
    // Fixed email regex pattern
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      showError("Please enter a valid email address");
      return;
    }
    
    if (password.length < 6) {
      showError("Password should be at least 6 characters");
      return;
    }

    // Set loading state
    setState(() => isLoading = true);

    try {
      // Check if phone number is already registered
      final phoneDoc = await firestore.collection("users").doc(fullPhone).get();
      if (phoneDoc.exists) {
        showError("Phone number already registered");
        return; // This correctly stops execution
      }

      // Check if email already exists before trying to create account
      bool emailExists = false;
      try {
        final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        emailExists = methods.isNotEmpty;
      } catch (e) {
        debugPrint("Error checking email: ${e.toString()}");
      }

      if (emailExists) {
        showError("Email already in use");
        return;
      }

      // Create user account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email
      await userCredential.user!.sendEmailVerification();
      
      // Create a user document in Firestore with pending status
      final userData = {
        'name': name,
        'email': email,
        'gender': selectedGender,
        'createdAt': DateTime.now().toIso8601String(),
        'emailVerified': false,
        'uid': userCredential.user!.uid,
      };
      
      // Store user data temporarily - it will be confirmed after email verification
      await firestore.collection("pendingUsers").doc(fullPhone).set(userData);

      // Navigate to verification screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/verifyEmail',
          arguments: {
            'phone': fullPhone,
            'userData': userData,
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      if (e.code == 'email-already-in-use') {
        showError("Email already in use");
      } else if (e.code == 'weak-password') {
        showError("Password is too weak");
      } else if (e.code == 'invalid-email') {
        showError("Invalid email format");
      } else {
        showError("Registration failed: ${e.message}");
      }
    } catch (e) {
      debugPrint("General Error: ${e.toString()}");
      showError("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/paneer.jpg', fit: BoxFit.cover),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/Logo.png', width: 200, height: 200),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Register",
                            style: TextStyle(
                              fontFamily: 'Righteous',
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(255, 160, 59, 1),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Fill in your details to register",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          buildTextField(nameController, "Name"),
                          const SizedBox(height: 15),
                          buildTextField(emailController, "Email", type: TextInputType.emailAddress),
                          const SizedBox(height: 15),
                          buildTextField(passwordController, "Password", obscure: true),
                          const SizedBox(height: 15),
                          buildGenderDropdown(),
                          const SizedBox(height: 15),
                          buildPhoneField(),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(254, 174, 0, 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              onPressed: isLoading ? null : registerUser,
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Register", style: TextStyle(fontFamily: 'RethinkSans-Bold',fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color.fromRGBO(254, 174, 0, 1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/phone'),
                              child: const Text(
                                "Back to Login",
                                style: TextStyle(
                                  fontFamily: "RethinkSans-Bold",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(254, 174, 0, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint, {TextInputType? type, bool obscure = false}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: controller,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(border: InputBorder.none, hintText: hint),
        ),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedGender,
            items: ["Male", "Female", "Other"]
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (value) => setState(() => selectedGender = value!),
          ),
        ),
      ),
    );
  }

  Widget buildPhoneField() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: TextField(
              controller: countryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const Text("|", style: TextStyle(fontSize: 33, color: Colors.grey)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Phone"),
            ),
          ),
        ],
      ),
    );
  }
}