import 'package:flutter/material.dart';

class RequestItemsBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> availableItems;
  final String vendorName;
  final String pickupStart;
  final String pickupEnd;
  final Future<bool> Function() onReserve;

  const RequestItemsBottomSheet({
    Key? key,
    required this.availableItems,
    required this.vendorName,
    required this.pickupStart,
    required this.pickupEnd,
    required this.onReserve,
  }) : super(key: key);

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_bag,
                size: 60,
                color: Color(0xFF2d6a4f),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reservation Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your bag from $vendorName is reserved',
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2d6a4f),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Donation Bag from $vendorName",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Pickup Time: $pickupStart - $pickupEnd",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...availableItems.map(
                (item) => ListTile(
              title: Text(item['name'] ?? 'Bag'),
              subtitle: Text("Available: ${item['quantity'] ?? 'N/A'}"),
              leading: const Icon(Icons.fastfood),
            ),
          ).toList(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final success = await onReserve();
              if (success && context.mounted) {
                Navigator.pop(context);
                _showSuccessDialog(context);
              }
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text("Reserve This Bag"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2d6a4f),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}