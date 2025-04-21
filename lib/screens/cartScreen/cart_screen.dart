import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../details/food_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:upi_pay/upi_pay.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();
  List<ApplicationMeta> _apps = [];
  bool _isLoadingApps = true;
  String? _upiError;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUpiApps();
    });
  }

  Future<void> _fetchUpiApps() async {
    try {
      setState(() {
        _isLoadingApps = true;
        _upiError = null;
      });

      final upiPay = UpiPay();
      final apps = await upiPay.getInstalledUpiApplications();
      print(
        "Detected UPI apps: ${apps.map((app) => app.upiApplication.getAppName()).toList()}",
      );

      if (mounted) {
        setState(() {
          _apps = apps;
          _isLoadingApps = false;
        });
      }
    } catch (e) {
      print("Error fetching UPI apps: $e");
      if (mounted) {
        setState(() {
          _isLoadingApps = false;
          _upiError = e.toString();
        });
      }
    }
  }

  double calculateTotal() {
    return cart.fold(
      0,
      (sum, item) => sum + item.foodItem['price'] * item.quantity,
    );
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  void incrementQuantity(int index) {
    setState(() {
      cart[index].quantity++;
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }

  Future<String> saveOrderToDatabase({
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final String orderId = _uuid.v4();
      final User? currentUser = _auth.currentUser;
      final String userId = currentUser?.uid ?? 'guest';
      final timestamp = FieldValue.serverTimestamp();

      final List<Map<String, dynamic>> orderItems =
          items.map((item) {
            return {
              'name': item['foodItem']['name'],
              'price': item['foodItem']['price'],
              'quantity': item['quantity'],
              'image': item['foodItem']['image'],
              'subtotal': item['foodItem']['price'] * item['quantity'],
            };
          }).toList();

      final Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userId': userId,
        'items': orderItems,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      if (currentUser != null) {
        orderData['userEmail'] = currentUser.email;
        orderData['userName'] = currentUser.displayName;

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(orderId)
            .set({
              'orderId': orderId,
              'total': total,
              'status': 'pending',
              'createdAt': timestamp,
            });
      }

      await _firestore.collection('orders').doc(orderId).set(orderData);
      return orderId;
    } catch (e) {
      print('Error saving order: $e');
      throw Exception('Failed to save order: $e');
    }
  }

  void initiateUpiTransaction(ApplicationMeta app, double amount) async {
    try {
      final upiPay = UpiPay();
      final response = await upiPay.initiateTransaction(
        amount: amount.toStringAsFixed(2),
        app: app.upiApplication,
        receiverUpiAddress: 'yourupi@bank', // replace with actual UPI ID
        receiverName: 'DineGo Test Store',
        transactionRef: 'txn-${DateTime.now().millisecondsSinceEpoch}',
        transactionNote: 'Payment for Order',
      );

      if (response.status == UpiTransactionStatus.success) {
        final subtotal = calculateTotal();
        final deliveryFee = subtotal > 300 ? 0 : 40;
        final total = subtotal + deliveryFee;
        final List<Map<String, dynamic>> orderItems =
            cart
                .map(
                  (item) => {
                    'foodItem': item.foodItem,
                    'quantity': item.quantity,
                  },
                )
                .toList();

        final String orderId = await saveOrderToDatabase(
          subtotal: subtotal,
          deliveryFee: deliveryFee.toDouble(),
          total: total,
          paymentMethod: 'UPI - ${app.upiApplication.getAppName()}',
          items: orderItems,
        );

        clearCart();
        Navigator.pushNamed(
          context,
          '/order-confirmation',
          arguments: {'orderId': orderId},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction failed: ${response.status}')),
        );
      }
    } catch (e) {
      print('UPI error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Widget _buildPaymentOptions(double totalWithDelivery) {
    if (_isLoadingApps) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_upiError != null) {
      return Column(
        children: [
          Text(
            'Could not load UPI apps: $_upiError',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _fetchUpiApps, child: const Text('Retry')),
          const SizedBox(height: 12),
          // Fallback UPI button
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Pay with UPI'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please install a UPI app or select another payment method',
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    if (_apps.isEmpty) {
      return Column(
        children: [
          const Text(
            'No UPI apps found on your device',
            style: TextStyle(color: Colors.orange),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Pay with UPI'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please install a UPI app to continue'),
                ),
              );
            },
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          _apps.map((app) {
            return ElevatedButton.icon(
              icon: app.iconImage(24),
              label: Text('Pay with ${app.upiApplication.getAppName()}'),
              onPressed:
                  () => initiateUpiTransaction(
                    app,
                    totalWithDelivery,
                  ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateTotal();
    final totalString = total.toStringAsFixed(2);
    final deliveryFee = total > 300 ? 0 : 40;
    final totalWithDelivery = (total + deliveryFee).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Clear Cart',
              onPressed: () {
                clearCart();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Cart cleared')));
              },
            ),
        ],
      ),
      body:
          cart.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              item.foodItem['image'],
                              width: 50,
                              height: 50,
                            ),
                            title: Text(item.foodItem['name']),
                            subtitle: Text(
                              '₹${item.foodItem['price']} x ${item.quantity}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => decrementQuantity(index),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => incrementQuantity(index),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${(item.foodItem['price'] * item.quantity).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text('₹$totalString'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              deliveryFee > 0
                                  ? 'Delivery Fee'
                                  : 'Delivery Fee (Free over ₹300)',
                            ),
                            Text(
                              deliveryFee > 0
                                  ? '₹${deliveryFee.toStringAsFixed(0)}'
                                  : 'FREE',
                            ),
                          ],
                        ),
                        const Divider(thickness: 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹$totalWithDelivery',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Payment Methods',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOptions(double.parse(totalWithDelivery)),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.monetization_on),
                          label: const Text('Pay on Delivery'),
                          onPressed: () => processPayOnDelivery(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> processPayOnDelivery() async {
    try {
      final subtotal = calculateTotal();
      final deliveryFee = subtotal > 300 ? 0 : 40;
      final total = subtotal + deliveryFee;

      final List<Map<String, dynamic>> orderItems =
          cart
              .map(
                (item) => {
                  'foodItem': item.foodItem,
                  'quantity': item.quantity,
                },
              )
              .toList();

      final String orderId = await saveOrderToDatabase(
        subtotal: subtotal,
        deliveryFee: deliveryFee.toDouble(),
        total: total,
        paymentMethod: 'Cash on Delivery',
        items: orderItems,
      );

      clearCart();
      Navigator.pushNamed(
        context,
        '/order-confirmation',
        arguments: {'orderId': orderId},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: ${e.toString()}')),
      );
    }
  }
}
