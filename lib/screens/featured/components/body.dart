import 'package:flutter/material.dart';
import '../../../data/food_data.dart'; // Adjust path if needed
import '../../home/components/food_item_list.dart'; // Adjust path if needed

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    final popularFoodItems = foodItems.where((item) => item['isPopular'] == true).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Most Popular",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          FoodItemList(
            foodItems: popularFoodItems,
            isVertical: true,
          ),
        ],
      ),
    );
  }
}
