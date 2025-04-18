import 'package:flutter/material.dart';
import 'package:nawaproject/constants.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyOrders = [
      {'id': '#1001', 'item': 'Pizza Margherita', 'date': 'Apr 15, 2025', 'price': '\$8.99'},
      {'id': '#1002', 'item': 'Cheese Burger', 'date': 'Apr 12, 2025', 'price': '\$6.49'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: dummyOrders.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final order = dummyOrders[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(order['id']!.substring(1)),
            ),
            title: Text(order['item']!),
            subtitle: Text(order['date']!),
            trailing: Text(order['price']!),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reorder ${order['item']}')),
              );
            },
          );
        },
      ),
    );
  }
}
