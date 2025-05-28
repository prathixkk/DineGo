
import 'package:flutter/material.dart';
import 'package:dinego/components/cards/iteam_card.dart';
import 'package:dinego/constants.dart';

class Items extends StatelessWidget {
  const Items({
    super.key,
    required this.demoData,
  }); 

  final List<Map<String, dynamic>>
  demoData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: defaultPadding / 2),
        ...List.generate(
          demoData.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding / 2,
            ),
            child: ItemCard(
              title: demoData[index]["name"] ?? "No Title",
              description: demoData[index]["location"] ?? "No Location",
              image: demoData[index]["image"] ?? "No Image",
              foodType: demoData[index]["foodType"] ?? "Fried",
              price: 0,
              priceRange: "\$ \$",
              press: () {},
            ),
          ),
        ),
      ],
    );
  }
}
