import 'package:flutter/material.dart';
import '../../../data/food_data.dart';
import '/../constants.dart';
import '../../details/food_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? restaurantId;
  const SearchScreen({Key? key, this.restaurantId}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  String sortBy = 'rating'; // rating | price | calories
  bool onlyPopular = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredItems() {
    final menu = restaurantMenus[widget.restaurantId]?['menu'] ?? [];
    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(menu);

    if (onlyPopular) {
      items = items.where((item) => item['isPopular'] == true).toList();
    }

    if (searchQuery.isNotEmpty) {
      items =
          items
              .where(
                (item) => item['name'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    switch (sortBy) {
      case 'price':
        items.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'calories':
        items.sort(
          (a, b) => a['calories']['total'].compareTo(b['calories']['total']),
        );
        break;
      case 'rating':
      default:
        items.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final results = getFilteredItems();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Search Menu"), elevation: 0),
      body: Column(
        children: [
          Container(
            color: theme.primaryColor.withOpacity(0.05),
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search food...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => searchQuery = '');
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: sortBy,
                          hint: const Text('Sort by'),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: const [
                            DropdownMenuItem(
                              value: 'rating',
                              child: Text('Top Rated'),
                            ),
                            DropdownMenuItem(
                              value: 'price',
                              child: Text('Price: Low to High'),
                            ),
                            DropdownMenuItem(
                              value: 'calories',
                              child: Text('Calories: Low to High'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => sortBy = value);
                          },
                        ),
                      ),
                    ),
                    FilterChip(
                      label: const Text("Popular Only"),
                      selected: onlyPopular,
                      onSelected: (val) => setState(() => onlyPopular = val),
                      avatar: Icon(
                        Icons.star,
                        size: 16,
                        color: onlyPopular ? Colors.white : Colors.amber,
                      ),
                      selectedColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: onlyPopular ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${results.length} results found',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Sorted by: ${sortBy.capitalize()}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                results.isEmpty
                    ? const Center(
                      child: Text('No results found. Try a different search.'),
                    )
                    : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FoodDetailsScreen(
                                        foodItem: {
                                          ...item,
                                          'restaurant':
                                              restaurantMenus[widget
                                                  .restaurantId]!['restaurant'],
                                          'restaurantId': widget.restaurantId,
                                        },
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.restaurant,
                                      color: theme.primaryColor,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['name'],
                                                style: theme
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    item['rating'].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "₹${item['price']} • ${item['calories']['total']} kcal",
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        if (item['isPopular'] == true)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.thumb_up,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Popular choice',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.amber[800],
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
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
