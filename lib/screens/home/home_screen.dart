import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/cards/big/big_card_image_slide.dart';
import '../../components/section_title.dart';
import '../../constants.dart';
import '../../data/food_data.dart';
import '../featured/most_popular.dart';
import '../profile/profile_screen.dart';
import 'components/food_item_list.dart';
import '../QrScanner/qr_scanner_screen.dart';

// Demo images (or import from food_data if centralized)
const List<String> demoBigImages = [
  "assets/images/burger slide.png",
  "assets/images/next slide.png",
  "assets/images/uncle_phon_chicken.png",
  "assets/images/golden_chicken.png",
  "assets/images/street_chicken.png",
];

class HomeScreen extends StatefulWidget {
  final String? restaurantId;
  const HomeScreen({this.restaurantId, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationStr = "loading...";
  int _selectedIndex = 0;
  String? _restaurantId;
  String restaurantName = "";

  _HomeScreenState() {
    requestLocation();
  }

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  void _loadRestaurantData() async {
    String? restaurantId = widget.restaurantId;

    if (restaurantId == null) {
      final prefs = await SharedPreferences.getInstance();
      restaurantId = prefs.getString('selected_restaurant_id');
    }

    setState(() {
      _restaurantId = restaurantId;

      if (_restaurantId != null && restaurantMenus.containsKey(_restaurantId)) {
        restaurantName = restaurantMenus[_restaurantId]!['restaurant'];
      } else {
        restaurantName = "All Restaurants";
      }
    });
  }

  void requestLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) async {
      double? lat = currentLocation.latitude;
      double? lon = currentLocation.longitude;
      if (lat == null || lon == null) return;

      String newLocation = await reverseSearchLocation(lat, lon);
      setState(() {
        locationStr = newLocation;
      });
    });
  }

  Future<String> reverseSearchLocation(double lat, double lon) async {
    final res = await http.get(
      Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=jsonv2",
      ),
      headers: {'Accept-Language': 'en'},
    );

    final json = jsonDecode(res.body);

    final address = json['address'];
    final road = address['road'] ?? '';
    final neighborhood = address['neighbourhood'] ?? '';
    final city = address['city'] ?? address['town'] ?? address['village'] ?? '';

    return "$road, $neighborhood, $city".trim().replaceAll(
      RegExp(r'^,+|,+$'),
      '',
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home - do nothing
        break;
      case 1:
        // Search (to be implemented)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Search screen not implemented yet")),
        );
        break;
      case 2:
        // Orders
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Orders screen not implemented yet")),
        );
        break;
      case 3:
        // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999.0),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image(
                image:
                    FirebaseAuth.instance.currentUser?.photoURL != null
                        ? NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL!,
                        )
                        : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              restaurantName,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: primaryColor,
                fontFamily: 'RethinkSans-Bold',
              ),
            ),
            Text(
              locationStr,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'RethinkSans-Regular',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerScreen()),
              ).then((_) => _loadRestaurantData());
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: BigCardImageSlide(images: demoBigImages),
              ),
              const SizedBox(height: defaultPadding * 2),
              SectionTitle(
                title: "Menu",
                press:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MostPopularScreen(
                              restaurantId: _restaurantId ?? '',
                            ),
                      ),
                    ),
              ),
              const SizedBox(height: defaultPadding),
              FoodItemList(isVertical: false, restaurantId: _restaurantId),
              const SizedBox(height: 20),
              SectionTitle(
                title: "All Menu Items",
                press:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MostPopularScreen(
                              restaurantId: _restaurantId ?? '',
                            ),
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              FoodItemList(isVertical: true, restaurantId: _restaurantId),
              const SizedBox(height: 39),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ), // ✅ NEW
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
