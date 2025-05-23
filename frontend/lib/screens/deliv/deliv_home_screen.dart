import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import 'deliv_order_card.dart';
import 'deliv_order_details.dart';
import 'deliv_profile.dart';
import 'deliveries.dart';

// The main screen for the delivery partner (driver) home page
class DelivHomeScreen extends StatefulWidget {
  const DelivHomeScreen({super.key});

  @override
  State<DelivHomeScreen> createState() => _DelivHomeScreenState();
}

class _DelivHomeScreenState extends State<DelivHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0; // Track the selected bottom navigation index
  bool _isOnline = true; // Track the online/offline status

  // Sample active deliveries data
  List<Map<String, dynamic>> _activeDeliveries = [
    {
      'id': '#SGO-2023-0456',
      'restaurant': 'Daylight Coffee',
      'customer': 'John Smith',
      'address': '123 Green St, Beirut',
      'items': 3,
      'distance': 2.5,
      'price': 18.50,
      'status': 'pickup',
      'time': DateTime.now().add(const Duration(minutes: 15)),
    },
    {
      'id': '#SGO-2023-0457',
      'restaurant': 'Mario Italiano',
      'customer': 'Sarah Johnson',
      'address': '456 Pine Ave, Beirut',
      'items': 2,
      'distance': 3.2,
      'price': 24.75,
      'status': 'delivery',
      'time': DateTime.now().add(const Duration(minutes: 45)),
    },
  ];

  // Sample completed deliveries data
  List<Map<String, dynamic>> _completedDeliveries = [
    {
      'id': '#SGO-2023-0455',
      'restaurant': 'The Halal Guys',
      'customer': 'Michael Brown',
      'address': '789 Oak Blvd, Beirut',
      'items': 4,
      'distance': 1.8,
      'price': 32.00,
      'status': 'completed',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];

  // Function to handle bottom navigation item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to update delivery status and move completed deliveries to the completed list
  void _updateDeliveryStatus(String id, String newStatus) {
    setState(() {
      // Find the delivery in active deliveries
      var deliveryIndex = _activeDeliveries.indexWhere((d) => d['id'] == id);
      if (deliveryIndex != -1) {
        // Update the status
        _activeDeliveries[deliveryIndex]['status'] = newStatus;

        // If completed, move it to the completed deliveries list
        if (newStatus == 'completed') {
          _completedDeliveries.insert(0, _activeDeliveries[deliveryIndex]);
          _activeDeliveries.removeAt(deliveryIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // To get the current theme
    final size = MediaQuery.of(context).size; // To get the screen size

    return Scaffold(
      key: _scaffoldKey, // Scaffold key for accessing the scaffold's state
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery Partner",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2d6a4f), // App bar background color
        elevation: 4, // App bar shadow elevation
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          // Button to toggle online/offline status
          IconButton(
            icon: Icon(
              _isOnline ? Icons.location_on : Icons.location_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isOnline = !_isOnline; // Toggle online/offline status
              });
              // Show a snackbar with the new status
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isOnline
                        ? 'You are now online and available for deliveries'
                        : 'You are now offline',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex, // Control which tab is displayed
        children: [
          // Home Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(
              defaultPadding,
            ), // Padding around the content
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align children to the left
              children: [
                // Online/Offline Status Card
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green[50] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isOnline ? Colors.green : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon indicating online/offline status
                      Icon(
                        _isOnline ? Icons.check_circle : Icons.pause_circle,
                        color: _isOnline ? Colors.green : Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Ali!",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              _isOnline
                                  ? 'You are online and available for orders'
                                  : 'You are currently offline',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isOnline
                                  ? 'New orders will be assigned to you'
                                  : 'You will not receive new orders',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: defaultPadding), // Spacer
                // Active Deliveries Section
                if (_activeDeliveries.isNotEmpty) ...[
                  Text(
                    'Active Deliveries',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Map each active delivery to a card widget
                  ..._activeDeliveries.map(
                    (delivery) => DelivOrderCard(
                      delivery: delivery,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => DelivOrderDetails(
                                    delivery: delivery,
                                    onStatusUpdate:
                                        (newStatus) => _updateDeliveryStatus(
                                          delivery['id'],
                                          newStatus,
                                        ),
                                  ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding), // Spacer
                ],

                // Completed Deliveries Section
                Text(
                  'Recent Deliveries',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Map each completed delivery to a card widget
                ..._completedDeliveries.map(
                  (delivery) => DelivOrderCard(
                    delivery: delivery,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DelivOrderDetails(
                                  delivery: delivery,
                                  onStatusUpdate:
                                      (newStatus) => _updateDeliveryStatus(
                                        delivery['id'],
                                        newStatus,
                                      ),
                                ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Deliveries Tab - Shows completed deliveries
          DeliveriesScreen(completedDeliveries: _completedDeliveries),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/vehicle.svg',
              width: 24,
              height: 24,
            ),
            label: 'Deliveries',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected tab
        selectedItemColor: const Color(0xFF2d6a4f),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // If Profile tab is selected, navigate to profile screen
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DelivProfileScreen(),
              ),
            );
          } else {
            _onItemTapped(index); // Otherwise, switch tabs
          }
        },
        backgroundColor: Colors.white, // Bottom bar background color
        elevation: 10, // Bottom bar elevation for shadow effect
      ),
    );
  }
}
