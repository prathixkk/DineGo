import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import '../../../components/scalton/medium_card_scalton.dart';
import '../../details/food_details_screen.dart';
import '../../../data/food_data.dart';

class FoodItemList extends StatefulWidget {
  final bool isVertical;
  final String? restaurantId;
  final bool filterPopular;

  const FoodItemList({
    Key? key,
    this.isVertical = false,
    this.restaurantId,
    this.filterPopular = false,
  }) : super(key: key);

  @override
  _FoodItemListState createState() => _FoodItemListState();
}

class _FoodItemListState extends State<FoodItemList> {
  bool isLoading = true;
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurantMenu();
  }

  Future<void> _loadRestaurantMenu() async {
    String? restaurantId = widget.restaurantId;

    if (restaurantId == null) {
      final prefs = await SharedPreferences.getInstance();
      restaurantId = prefs.getString('selected_restaurant_id');
    }

    if (restaurantId != null && restaurantMenus.containsKey(restaurantId)) {
      List<Map<String, dynamic>> menuItems = List<Map<String, dynamic>>.from(
        restaurantMenus[restaurantId]!['menu'],
      );

      if (widget.filterPopular) {
        menuItems =
            menuItems.where((item) => item['isPopular'] == true).toList();
      }

      setState(() {
        foodItems =
            menuItems.map((item) {
              return {
                ...item,
                'restaurant': restaurantMenus[restaurantId]!['restaurant'],
                'restaurantId': restaurantId,
              };
            }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        foodItems = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return buildLoadingIndicator();

    if (foodItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_food, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "No food items available for this restaurant",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/qr_scanner');
                },
                child: const Text("Scan Another Restaurant"),
              ),
            ],
          ),
        ),
      );
    }

    return widget.isVertical
        ? Column(
          children:
              foodItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: 8,
                  ),
                  child: FoodItemCard(foodItem: item, isFullWidth: true),
                );
              }).toList(),
        )
        : SizedBox(
          width: double.infinity,
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foodItems.length,
            itemBuilder:
                (context, index) => Padding(
                  padding: EdgeInsets.only(
                    left: defaultPadding,
                    right: index == foodItems.length - 1 ? defaultPadding : 0,
                  ),
                  child: FoodItemCard(foodItem: foodItems[index]),
                ),
          ),
        );
  }

  SingleChildScrollView buildLoadingIndicator() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          2,
          (index) => const Padding(
            padding: EdgeInsets.only(left: defaultPadding),
            child: MediumCardScalton(),
          ),
        ),
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> foodItem;
  final bool isFullWidth;

  const FoodItemCard({
    Key? key,
    required this.foodItem,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsScreen(foodItem: foodItem),
          ),
        );
      },
      child: Container(
        width: isFullWidth ? double.infinity : 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 10),
              blurRadius: 50,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                foodItem['image'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Righteous-Regular',
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "from ${foodItem['restaurant']}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        foodItem['rating'].toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${foodItem['calories']['total']} kcal",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${foodItem['price']}",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontFamily: 'RethinkSans-Bold',
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'RethinkSans-Regular',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
