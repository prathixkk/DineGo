import 'package:flutter/material.dart';
import 'package:nawaproject/constants.dart';
import 'user_info_screen.dart';
import 'order_history_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings pressed')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildProfileMenu(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: Text(
              'J',
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'John Doe',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            'john.doe@example.com',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out')),
              );
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
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue[700]),
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
