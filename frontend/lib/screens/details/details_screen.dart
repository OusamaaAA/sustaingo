import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants.dart';
import 'components/items.dart';
import 'components/restaurrant_info.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> vendor; // Vendor data passed to the screen

  const DetailsScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Back button icon
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context), // Navigate back when pressed
        ),
        title: Row(
          children: const [
            Icon(
              Icons.restaurant_outlined, // Icon representing a restaurant
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              "Restaurant Details", // Title of the app bar
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true, // Centers the title
        backgroundColor: const Color(0xFF2d6a4f), // App bar background color
        elevation: 4, // Elevation of the app bar for shadow effect
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Rounded bottom corners of the app bar
          ),
        ),
        actions: [
          const SizedBox(width: 8), // Spacer to balance the app bar
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Enables scrolling for the body content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding / 2), // Add some space at the top
              RestaurantInfo(vendor: vendor), // Displays restaurant info using the vendor data
              const SizedBox(height: defaultPadding), // Space between sections
              Items(vendorId: vendor['id']), // Displays items for the specific vendor
            ],
          ),
        ),
      ),
    );
  }
}
