import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class DeliveriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> completedDeliveries;

  const DeliveriesScreen({
    super.key,
    required this.completedDeliveries,
  });

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  // Formatter for currency display
  final formatter = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title of the screen showing the number of completed deliveries
          Text(
            'All Delivered Orders (${widget.completedDeliveries.length})',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // If there are no completed deliveries, show a message
          if (widget.completedDeliveries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No completed deliveries yet',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            // Card to display completed deliveries
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Column(
                children: [
                  // Loop over all completed deliveries and display each one
                  ...widget.completedDeliveries.map((delivery) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side: Delivery ID, Restaurant, and Time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      delivery['id'] as String,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      delivery['restaurant'] as String,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    // Format and display the delivery time
                                    Text(
                                      DateFormat('MMM d, h:mm a')
                                          .format(delivery['time'] as DateTime),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Right side: Price and Delivery Status
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Display price with currency formatting
                                  Text(
                                    formatter.format(delivery['price'] as double),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2d6a4f),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Delivery status as "Completed"
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Add a divider between deliveries if this isn't the last one
                        if (delivery != widget.completedDeliveries.last)
                          const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
