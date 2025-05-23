import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/sign_in_screen.dart';
import '../../services/api_service.dart';
import 'add_mystery_bag_screen.dart';
import 'edit_mystery_bag_screen.dart';
import 'my_bags_screen.dart';
import 'vendor_reservation_screen.dart';
import 'vendor_profile_screen.dart';
import 'vendor_dashboard.dart';
import 'vendor_reviews_screen.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  int _selectedIndex = 0; // Keeps track of selected tab

  // List of screens corresponding to each tab
  final List<Widget> _screens = [
    const VendorDashboard(),
    const MyBagsScreen(),
    const VendorReservationsScreen(),
    const VendorReviewsScreen(),
    const VendorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkTokenPresence(); // Check if the user has a valid token on app startup
  }

  // Check for the presence of the authentication token
  Future<void> _checkTokenPresence() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      print('🔴 No access token found. Redirecting to login...');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    }
  }

  // Conditionally build the app bar based on the selected index
  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3 || _selectedIndex == 4) {
      return null; // No app bar for certain screens (e.g., My Bags, Reservations, etc.)
    } else {
      return AppBar(
        title: const Text(
          'Vendor Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      );
    }
  }

  // Handle bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Build the app bar based on the selected screen
      body: _screens[_selectedIndex], // Display the selected screen
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2d6a4f),
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddMysteryBagScreen()),
                );
                if (result == true) {
                  setState(() {}); // Refresh the screen if a new bag is added
                }
              },
            )
          : null, // Only show the floating action button on the "My Bags" screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Current tab
        onTap: _onItemTapped, // Update selected tab
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2d6a4f), // Selected tab color
        unselectedItemColor: Colors.grey, // Unselected tab color
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'My Bags'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Reservations'),
          BottomNavigationBarItem(icon: Icon(Icons.reviews), label: 'Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
