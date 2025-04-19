import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../components/scalton/medium_card_scalton.dart';
import '../../details/food_details_screen.dart';

class FoodItemList extends StatefulWidget {
  final List<Map<String, dynamic>> foodItems;
  final bool isVertical;

  const FoodItemList({
    Key? key,
    required this.foodItems,
    this.isVertical = false,
  }) : super(key: key);

  @override
  _FoodItemListState createState() => _FoodItemListState();
}

class _FoodItemListState extends State<FoodItemList> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return buildLoadingIndicator();

    return widget.isVertical
        ? SingleChildScrollView(
          child: Column(
            children:
                widget.foodItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: 8,
                    ),
                    child: FoodItemCard(foodItem: item, isFullWidth: true),
                  );
                }).toList(),
          ),
        )
        : SizedBox(
          width: double.infinity,
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.foodItems.length,
            itemBuilder:
                (context, index) => Padding(
                  padding: EdgeInsets.only(
                    left: defaultPadding,
                    right:
                        (widget.foodItems.length - 1) == index
                            ? defaultPadding
                            : 0,
                  ),
                  child: FoodItemCard(foodItem: widget.foodItems[index]),
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
        height: 254,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image
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
            // Food details
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

                  // ➕ Rating and Calories Row
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        foodItem['rating'].toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${foodItem['calories']} kcal",
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
