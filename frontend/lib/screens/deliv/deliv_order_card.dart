import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// A custom widget for displaying delivery order details
class DelivOrderCard extends StatelessWidget {
  // The data for a delivery order
  final Map<String, dynamic> delivery;
  // Callback function for tapping the card
  final VoidCallback onTap;

  // Constructor that requires delivery data and a callback for tap events
  const DelivOrderCard({
    super.key,
    required this.delivery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);  // Get the current theme for styling
    // Determine the status color based on the delivery status
    final statusColor = delivery['status'] == 'completed'
        ? Colors.green
        : delivery['status'] == 'pickup'
        ? Colors.orange
        : Colors.blue;

    // Build the card widget that displays delivery information
    return Card(
      margin: const EdgeInsets.only(bottom: 12), // Bottom margin to separate cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the card
      ),
      elevation: 2,  // Card shadow for elevation effect
      child: InkWell(
        borderRadius: BorderRadius.circular(12),  // Rounded corners for tap effect
        onTap: onTap,  // Trigger the onTap callback when the card is tapped
        child: Padding(
          padding: const EdgeInsets.all(16),  // Padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,  // Align content to the left
            children: [
              // Row for order ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Display the order ID with bold text
                  Text(
                    delivery['id'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,  // Make the order ID bold
                    ),
                  ),
                  // Status badge that changes color based on delivery status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),  // Background color with opacity
                      borderRadius: BorderRadius.circular(12),  // Rounded corners for the status badge
                    ),
                    child: Text(
                      delivery['status'].toString().toUpperCase(),  // Display status in uppercase
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,  // Text color matches the status color
                        fontWeight: FontWeight.bold,  // Make the status text bold
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),  // Add space between order ID and other details
              // Display restaurant and customer details
              Text(
                'From: ${delivery['restaurant']}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),  // Add space between lines
              Text(
                'To: ${delivery['customer']}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),  // Add space between lines
              Text(
                delivery['address'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],  // Change text color to gray for the address
                ),
              ),
              const SizedBox(height: 12),  // Add space before the next section
              // Row for displaying items, distance, and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Space out the items
                children: [
                  // Items count
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag, size: 16),  // Icon for items
                      const SizedBox(width: 4),  // Space between icon and text
                      Text(
                        '${delivery['items']} items',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  // Distance
                  Row(
                    children: [
                      const Icon(Icons.directions_bike, size: 16),  // Icon for distance
                      const SizedBox(width: 4),  // Space between icon and text
                      Text(
                        '${delivery['distance']} km',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  // Price
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),  // Icon for price
                      const SizedBox(width: 4),  // Space between icon and text
                      Text(
                        '${delivery['price']}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),  // Add space after the price row
              Divider(color: Colors.grey[300]),  // Add a divider between sections
              // Row for displaying the estimated time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Label for estimated time
                  Text(
                    'Estimated time',
                    style: theme.textTheme.bodySmall,
                  ),
                  // Display the formatted time (e.g., "3:30 PM")
                  Text(
                    DateFormat.jm().format(delivery['time']),  // Format the time
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,  // Make the time bold
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
