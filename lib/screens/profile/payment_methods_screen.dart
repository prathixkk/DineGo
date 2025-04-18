import 'package:flutter/material.dart';
import 'package:nawaproject/constants.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyCards = [
      {'type': 'Visa', 'number': '**** **** **** 4242'},
      {'type': 'MasterCard', 'number': '**** **** **** 1234'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: primaryColor,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: dummyCards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final card = dummyCards[index];
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Icon(Icons.credit_card, color: primaryColor),
            title: Text(card['type']!),
            subtitle: Text(card['number']!),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted ${card['type']}')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Payment Method')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
