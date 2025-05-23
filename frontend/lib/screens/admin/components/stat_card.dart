import 'package:flutter/material.dart';

// A stat card widget to display an icon, a numeric value, and a label
class StatCard extends StatelessWidget {
  final String title; // Title/label of the stat (e.g., "Orders")
  final String value; // The main statistic/value to display
  final IconData icon; // Icon representing the stat
  final Color color; // Theme color for the icon, value, and border

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, // Fixed width of the card
      height: 140, // Fixed height of the card
      padding: const EdgeInsets.all(16), // Padding inside the card
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Background with a light version of the color
        borderRadius: BorderRadius.circular(16), // Rounded corners
        border: Border.all(color: color.withOpacity(0.4)), // Border with semi-transparent color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
        children: [
          Icon(icon, color: color, size: 28), // Top icon with given color and size
          const SizedBox(height: 12), // Spacer between icon and value text
          Text(
            value, // Main stat value (e.g., "42")
            style: TextStyle(
              fontSize: 24, // Large font size for emphasis
              fontWeight: FontWeight.bold, // Bold text for importance
              color: color, // Text color matches the theme color
            ),
          ),
          const SizedBox(height: 4), // Spacer between value and title
          Text(
            title, // Title/label below the value (e.g., "Orders")
            style: const TextStyle(
              fontSize: 14, // Smaller font for subtitle
              color: Colors.black87, // Dark text color for readability
            ),
          ),
        ],
      ),
    );
  }
}
