// ✅ Refined Donation Bag Card for NGO View with consistent height and structure
import 'package:flutter/material.dart';

/// A card widget representing a donation bag for NGO users.
/// Displays bag info, vendor name, quantity, pickup time, and a button to view more.
class RestaurantInfoBigCardNgo extends StatelessWidget {
  // Title of the donation bag.
  final String bagTitle;

  // Short description of the bag contents.
  final String description;

  // Name of the vendor donating the bag.
  final String vendorName;

  // Quantity of items in the bag.
  final int quantity;

  // Start time for pickup.
  final String pickupStart;

  // End time for pickup.
  final String pickupEnd;

  // Callback function triggered when "View Bag" is pressed.
  final VoidCallback press;

  const RestaurantInfoBigCardNgo({
    super.key,
    required this.bagTitle,
    required this.description,
    required this.vendorName,
    required this.quantity,
    required this.pickupStart,
    required this.pickupEnd,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Fixed height to maintain card consistency across views.
      height: 240,
      child: Card(
        // Rounded corners and slight shadow.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title text with overflow handling.
              Text(
                bagTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Description text with overflow handling.
              Text(
                description,
                style: const TextStyle(color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Vendor name row with icon.
              _infoRow(Icons.storefront, vendorName),
              // Pickup time row with icon.
              _infoRow(Icons.timer, '$pickupStart - $pickupEnd'),
              // Quantity row with icon.
              _infoRow(Icons.inventory, 'Quantity: $quantity'),
              const Spacer(),
              // Button aligned to the bottom-right to view bag details.
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: press,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2d6a4f),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("View Bag", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget to build a row with an icon and a text.
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
