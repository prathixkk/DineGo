import 'package:flutter/material.dart';
import 'components/body.dart';

class MostPopularScreen extends StatelessWidget {
  final String restaurantId;

  const MostPopularScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Most Popular")),
      body: Body(restaurantId: restaurantId),
    );
  }
}
