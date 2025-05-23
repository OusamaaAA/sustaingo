import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../cards/big/big_card_image_slide.dart'; // Import the image slider
import '../../rating_with_counter.dart'; // You might not need this for NGOs
import '../../price_range_and_food_type.dart'; // You might adapt this or not use it

class RestaurantInfoBigCardNgo extends StatelessWidget {
  final String name;
  final String description;
  final String availableFood;
  final String contact;
  final VoidCallback press;
  final List<String> images; // Add images here

  const RestaurantInfoBigCardNgo({
    Key? key,
    required this.name,
    required this.description,
    required this.availableFood,
    required this.contact,
    required this.press,
    this.images = const [], // Initialize with an empty list
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty)
            BigCardImageSlide(images: images), // Show image slider if images are available
          if (images.isNotEmpty) const SizedBox(height: defaultPadding / 2),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(
            description,
            style: const TextStyle(color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Available Food:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(availableFood),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Contact:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(contact),
                ],
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: press,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2d6a4f),
                textStyle: const TextStyle(fontSize: 12), // Removed the extra 'padding' here
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2, vertical: defaultPadding / 4),
              ),
              child: const Text("Request Now", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}