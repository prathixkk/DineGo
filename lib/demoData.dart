final List<String> demoRestaurantNames = [
  "Fried Chicken Delight",
  "Korean Chicken House",
  "Uncle Phon's Crispy Chicken",
  "Golden Crispy Chicken",
  "Auntie's Street Chicken",
];


//Restaurant Images
final Map<String, String> restaurantImages = {
  "New Shahi Restaurant": "assets/images/fried_chicken1.png",
  "Korean Chicken House": "assets/images/korean_chicken.png",
  "Uncle Phon's Crispy Chicken": "assets/images/uncle_phon_chicken.png",
  "Golden Crispy Chicken": "assets/images/golden_chicken.png",
  "Auntie's Street Chicken": "assets/images/street_chicken.png",
};


//Banner
List<String> demoBigImages = [
  "assets/images/burger slide.png",
  "assets/images/next slide.png",
  "assets/images/uncle_phon_chicken.png",
  "assets/images/golden_chicken.png",
  "assets/images/street_chicken.png",
];


//All Restaurant Images
List<Map<String, dynamic>> demoMediumCardData = [
  {
    "name": "Korean Chicken House",
    "image": "assets/images/korean_chicken.png",
    "location": "Asoke, Bangkok",
    "rating": 8.6,
    "delivertTime": 20,
  },
  {
    "name": "Fried Chicken Delight",
    "image": "assets/images/fried_chicken1.png",
    "location": "Nana, Bangkok",
    "rating": 9.1,
    "delivertTime": 35,
  },
  {
    "name": "Uncle Phon's Crispy Chicken",
    "image": "assets/images/uncle_phon_chicken.png",
    "location": "Chitlom, Bangkok",
    "rating": 7.3,
    "delivertTime": 25,
  },
  {
    "name": "Golden Crispy Chicken",
    "image": "assets/images/golden_chicken.png",
    "location": "Thonglor, Bangkok",
    "rating": 8.4,
    "delivertTime": 30,
  },
  {
    "name": "Auntie's Street Chicken",
    "image": "assets/images/street_chicken.png",
    "location": "SWU, Bangkok",
    "rating": 9.5,
    "delivertTime": 15,
  },
];

final Map<String, List<Map<String, dynamic>>> restaurantMenu = {
  "Korean Chicken House": [
    {
      "name": "Spicy Korean Chicken",
      "location": "Asoke, Bangkok",
      "image": "assets/images/korean_chicken.png",
      "foodType": "Fried Chicken",
      "price": 99,
      "priceRange": "\$ \$",
    },
    {
      "name": "Hainanese Chicken Rice",
      "location": "Asoke, Bangkok",
      "image": "assets/images/golden_chicken.png",
      "foodType": "Rice Dish",
      "price": 79,
      "priceRange": "\$ \$",
    },
  ],
  "Fried Chicken Delight": [
    {
      "name": "Southern Thai Fried Chicken",
      "location": "Nana, Bangkok",
      "image": "assets/images/fried_chicken1.png",
      "foodType": "Fried Chicken",
      "price": 85,
      "priceRange": "\$ \$",
    },
    {
      "name": "Chicken Rice Combo",
      "location": "Nana, Bangkok",
      "image": "assets/images/golden_chicken.png",
      "foodType": "Rice Dish",
      "price": 70,
      "priceRange": "\$ \$",
    },
  ],
};
