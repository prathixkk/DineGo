import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nawaproject/constants.dart';
import 'user_info_screen.dart';
import 'order_history_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("No user signed in");

  // Try fetching from Firestore
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  if (doc.exists && doc.data() != null) {
    return doc.data()!;
  }

  // Fallback: Use FirebaseAuth fields
  return {
    'name': user.displayName ?? 'User',
    'email': user.email ?? 'No email',
    'photoUrl': user.photoURL ?? '',
  };
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User data not found"));
          }

          final userData = snapshot.data!;
          final name = userData['name'] ?? 'User';
          final email = userData['email'] ?? 'Email not available';

          return Column(
            children: [
              _buildProfileHeader(name, email),
              const SizedBox(height: 20),
              _buildProfileMenu(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: primaryColor),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _buildMenuButton(
            context,
            title: 'Your Profile',
            icon: Icons.person,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInfoScreen())),
          ),
          const SizedBox(height: 15),
          _buildMenuButton(
            context,
            title: 'Order History',
            icon: Icons.shopping_bag,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
          ),
          const SizedBox(height: 15),
          _buildMenuButton(
            context,
            title: 'Payment Methods',
            icon: Icons.payment,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
          ),
          const SizedBox(height: 15),
          _buildMenuButton(
            context,
            title: 'Sign Out',
            icon: Icons.logout,
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                debugPrint('User signed out');
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/phone', (route) => false);
                }
              } catch (e) {
                debugPrint('Sign out error: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to sign out.')),
                  );
                }
              }
            },
            color: Colors.red[400],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? primaryColor),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: color ?? Colors.black87),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
