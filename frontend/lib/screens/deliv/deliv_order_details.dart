import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';

// A screen to display the details of a delivery order.
class DelivOrderDetails extends StatefulWidget {
  final Map<String, dynamic> delivery;  // Delivery data
  final Function(String) onStatusUpdate;  // Callback to update delivery status

  const DelivOrderDetails({
    super.key,
    required this.delivery,
    required this.onStatusUpdate,
  });

  @override
  State<DelivOrderDetails> createState() => _DelivOrderDetailsState();
}

class _DelivOrderDetailsState extends State<DelivOrderDetails> {
  late Map<String, dynamic> _delivery;  // Local state to store delivery data

  @override
  void initState() {
    super.initState();
    _delivery = Map.from(widget.delivery);  // Initialize delivery data
  }

  // Helper method to build each item in the order summary
  Widget _buildOrderItem(BuildContext context, String name, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '\$$price',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // Method to update the delivery status and call the callback
  void _updateStatus() {
    String newStatus = _delivery['status']; // Get current status

    setState(() {
      // Update the status based on current state
      if (_delivery['status'] == 'pickup') {
        newStatus = 'delivery';
      } else if (_delivery['status'] == 'delivery') {
        newStatus = 'completed';
      }
      _delivery['status'] = newStatus;  // Update the delivery status
    });

    widget.onStatusUpdate(newStatus);  // Call the parent widget to update status
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine status color based on the current delivery status
    final statusColor = _delivery['status'] == 'completed'
        ? Colors.green
        : _delivery['status'] == 'pickup'
        ? Colors.orange
        : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order ${_delivery['id']}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),  // Rounded corners for the card
              ),
              elevation: 2,  // Card elevation for shadow effect
              child: Padding(
                padding: const EdgeInsets.all(16),  // Padding inside the card
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Status Icon based on the current delivery status
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),  // Light background color for icon
                            shape: BoxShape.circle,  // Circular shape for the icon background
                          ),
                          child: Icon(
                            _delivery['status'] == 'completed'
                                ? Icons.check_circle
                                : _delivery['status'] == 'pickup'
                                ? Icons.store
                                : Icons.delivery_dining,
                            color: statusColor,  // Color matching the delivery status
                          ),
                        ),
                        const SizedBox(width: 16),  // Space between the icon and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status text: "Delivery Completed", "Ready for Pickup", or "On the Way"
                              Text(
                                _delivery['status'] == 'completed'
                                    ? 'Delivery Completed'
                                    : _delivery['status'] == 'pickup'
                                    ? 'Ready for Pickup'
                                    : 'On the Way',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),  // Space between status title and description
                              Text(
                                _delivery['status'] == 'completed'
                                    ? 'Order was delivered successfully'
                                    : _delivery['status'] == 'pickup'
                                    ? 'Pick up from restaurant'
                                    : 'Delivering to customer',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar based on delivery status
                    LinearProgressIndicator(
                      value: _delivery['status'] == 'completed'
                          ? 1.0
                          : _delivery['status'] == 'pickup'
                          ? 0.33
                          : 0.66,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF2d6a4f),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    // Labels for progress steps (Order placed, Picked up, Delivered)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order placed',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'Picked up',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'Delivered',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),  // Space before next section

            // Restaurant Info Section
            Text(
              'RESTAURANT',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.grey,  // Grey color for section header
              ),
            ),
            const SizedBox(height: 8),  // Space before card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,  // Card elevation
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Restaurant icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: const Icon(Icons.store, size: 30, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant name
                          Text(
                            _delivery['restaurant'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Pickup time
                          Text(
                            'Pickup by: 12:30 PM',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    // Call restaurant button
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/call.svg',
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF2d6a4f),
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // Call restaurant logic
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),  // Space before next section

            // Customer Info Section
            Text(
              'CUSTOMER',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,  // Card elevation
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Customer icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: const Icon(Icons.person, size: 30, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer name
                          Text(
                            _delivery['customer'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Customer address
                          Text(
                            _delivery['address'],
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    // Call customer button
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/call.svg',
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF2d6a4f),
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // Call customer logic
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),  // Space before next section

            // Order Summary Section
            Text(
              'ORDER SUMMARY',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,  // Card elevation
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOrderItem(context, 'Mystery Bag (Large)', 12.00),
                    const Divider(),
                    _buildOrderItem(context, 'Rescued Pasta', 6.50),
                    const Divider(),
                    // Subtotal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '\$${_delivery['price']}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Delivery fee
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Fee',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '\$2.50',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Total cost
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${(_delivery['price'] + 2.5).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),  // Space before next section

            // Action Buttons Section
            if (_delivery['status'] != 'completed')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2d6a4f),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _updateStatus,
                      child: Text(
                        _delivery['status'] == 'pickup'
                            ? 'PICKED UP'
                            : 'DELIVERED',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
