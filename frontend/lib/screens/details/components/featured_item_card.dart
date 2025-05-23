import 'package:flutter/material.dart';

import '../../../components/small_dot.dart';
import '../../../constants.dart';

class FeaturedItemCard extends StatelessWidget {
  const FeaturedItemCard({
    super.key,
    required this.foodType,
    required this.image,
    required this.priceRange,
    required this.press,
    required this.title,
  });

  // Define variables to pass information about food type, image, price range, title, and on press action
  final String foodType, image, priceRange, title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    // Define text style for the price and food type, adjusting color and font weight
    TextStyle textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: titleColor.withOpacity(0.64),
          fontWeight: FontWeight.normal,
        );

    return InkWell(
      // Define a border radius for the clickable area
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onTap: press, // Handle the tap event
      child: Padding(
        padding: const EdgeInsets.all(5.0), // Add padding around the card
        child: SizedBox(
          width: 140, // Define a fixed width for the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
            children: [
              // Display an image with a 1:1 aspect ratio, clipped with rounded corners
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Image.asset(
                    image, // Image to display
                    fit: BoxFit.cover, // Ensure the image covers the box without distortion
                  ),
                ),
              ),
              const SizedBox(height: 8), // Add space between the image and title
              
              // Title of the item
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: titleColor, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8), // Add space between title and price/food type

              // Row displaying price range and food type
              Row(
                children: [
                  Text(
                    priceRange, // Price range text
                    style: textStyle,
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                    child: SmallDot(), // Visual separator (dot)
                  ),
                  Text(foodType, style: textStyle) // Food type text
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
