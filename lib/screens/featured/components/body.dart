import 'package:flutter/material.dart';
import '../../../data/food_data.dart';
import '../../home/components/food_item_list.dart';

class Body extends StatelessWidget {
  final String restaurantId;

  const Body({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> popularItems = [];

    if (restaurantMenus.containsKey(restaurantId)) {
      final restaurantName = restaurantMenus[restaurantId]!['restaurant'];
      final List<Map<String, dynamic>> menu = List<Map<String, dynamic>>.from(
        restaurantMenus[restaurantId]!['menu'],
      );

      final filtered =
          menu
              .where((item) => item['isPopular'] == true)
              .map((item) => {...item, 'restaurant': restaurantName})
              .toList();

      popularItems.addAll(filtered);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Most Popular",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (popularItems.isEmpty)
            const Center(
              child: Text("No popular items found for this restaurant."),
            )
          else
            ...popularItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FoodItemCard(foodItem: item, isFullWidth: true),
              ),
            ),
        ],
      ),
    );
  }
}
