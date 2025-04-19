import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nawaproject/constants.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool isLoading = true;
  String name = 'Loading...';
  String email = 'Loading...';
  String phone = 'Loading...';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    String? uid = user.uid;
    String? phoneNum = user.phoneNumber;

    try {
      DocumentSnapshot<Map<String, dynamic>>? doc;

      // First try with UID
      doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // If UID doc doesn't exist, try phone number
      if (!doc.exists && phoneNum != null) {
        doc = await FirebaseFirestore.instance.collection('users').doc(phoneNum).get();
      }

      if (doc.exists) {
        final userData = doc.data()!;
        setState(() {
          name = userData['name'] ?? user.displayName ?? 'No Name';
          email = userData['email'] ?? user.email ?? 'No Email';
          phone = phoneNum ?? 'No Phone';
          isLoading = false;
        });
      } else {
        // Fall back to FirebaseAuth data
        setState(() {
          name = user.displayName ?? 'No Name';
          email = user.email ?? 'No Email';
          phone = phoneNum ?? 'No Phone';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
      setState(() {
        name = 'Error';
        email = 'Error';
        phone = 'Error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(name),
                  const SizedBox(height: 20),
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(email),
                  const SizedBox(height: 20),
                  const Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(phone),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Profile pressed')),
                        );
                      },
                      child: const Text('Edit Profile'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
