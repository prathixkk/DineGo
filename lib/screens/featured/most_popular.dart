import 'package:flutter/material.dart';

import 'components/body.dart';

class MostPopularScreen extends StatelessWidget {
  const MostPopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Most Popular"),
      ),
      body: const Body(),
    );
  }
}
