// Flutter core and third-party imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Screen and component imports
import 'ngo_profile_screen.dart';
import 'request_items.dart';
import 'restaurant_ngo_cards.dart';
import '../../components/section_title.dart';
import '../../constants.dart';
import '../../../screens/auth/sign_in_screen.dart';

class NGOHomeScreen extends StatefulWidget {
  const NGOHomeScreen({super.key});

  @override
  State<NGOHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NGOHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Stores the NGO's dashboard stats
  Map<String, dynamic> _ngoSummary = {
    'total_donations': 0,
    'total_items_rescued': 0,
  };

  // Stores the list of donation bags fetched from the backend
  List<dynamic> _donationBags = [];

  @override
  void initState() {
    super.initState();
    // Trigger session check and data fetching after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleSession());
  }

  // Handles session token and loads necessary dashboard data
  Future<void> _handleSession() async {
    final ok = await _refreshToken();
    if (!ok) {
      _redirectToLogin();
      return;
    }
    await fetchDashboardSummary();
    await fetchDonationBags();
  }

  // Refresh access token using the refresh token
  Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');

    if (refresh == null) return false;

    final response = await http.post(
      Uri.parse('https://sustaingobackend.onrender.com/api/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    // Debug prints for token refresh process
    print("Attempting to refresh token...");
    print("Stored refresh: $refresh");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final newAccess = jsonDecode(response.body)['access'];
      await prefs.setString('auth_token', newAccess);
      return true;
    }

    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    return false;
  }

  // Redirects the user to the login screen
  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
    );
  }

  void _markAsCollected(String reservationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.patch(
      Uri.parse('https://sustaingobackend.onrender.com/api/reservations/$reservationId/collect/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Refresh both bags and summary data
      await _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully marked as collected')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  // Fetch NGO dashboard summary statistics
  Future<void> fetchDashboardSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('https://sustaingobackend.onrender.com/api/get_ngo_dashboard_summary/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _ngoSummary = {
          'total_donations': data['total_donations'] ?? 0,
          'total_items_rescued': data['total_items_rescued'] ?? 0,
        };
      });
    } else {
      print("Dashboard summary error: ${response.body}");
    }
  }

// Add a method to refresh both bags and summary
  Future<void> _refreshData() async {
    await fetchDonationBags();
    await fetchDashboardSummary();
  }

  // Fetch list of donation bags available for reservation
  Future<void> fetchDonationBags() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('https://sustaingobackend.onrender.com/api/get_donation_bags/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _donationBags = json.decode(response.body);
      });
    } else {
      print("Donation bags error: ${response.body}");
    }
  }

  // Shows a modal with available items in a donation bag and option to reserve it
  void _showAvailableItems(BuildContext context, Map<String, dynamic> bag, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return RequestItemsBottomSheet(
          availableItems: [
            {"name": bag['hidden_contents'], "quantity": bag['quantity_available']}
          ],
          vendorName: bag['vendor_name'],
          pickupStart: bag['pickup_start'],
          pickupEnd: bag['pickup_end'],
          onReserve: () async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');

            final response = await http.post(
              Uri.parse('https://sustaingobackend.onrender.com/api/bags/${bag['id']}/reserve/'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 201) {
              // Update local state for donation bags
              setState(() {
                _donationBags[index]['quantity_available'] -= 1;
                if (_donationBags[index]['quantity_available'] <= 0) {
                  _donationBags.removeAt(index);
                }
                // Increment the total items rescued locally
                _ngoSummary['total_items_rescued'] = (_ngoSummary['total_items_rescued'] as int) + 1;
              });

              // No need to call fetchDonationBags again immediately if you're updating the list locally
              // await fetchDonationBags();
              return true;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to reserve: ${response.body}')),
              );
              return false;
            }
          },
        );
      },
    );
  }

  // Builds the card displaying donation stats
  Widget _buildDonationStatsCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Impact Today",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: defaultPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "${_ngoSummary['total_donations']}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d6a4f),
                      ),
                    ),
                    const Text(
                      "Donations Collected",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  height: 30,
                  child: const VerticalDivider(color: Colors.grey),
                ),
                Column(
                  children: [
                    Text(
                      "${_ngoSummary['total_items_rescued']}+",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE67E22),
                      ),
                    ),
                    const Text(
                      "Food Items Rescued",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Main UI of the NGO Dashboard screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'NGO Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NGOProfileScreen()),
              );
            },
          ),
          const SizedBox(width: defaultPadding / 2),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: "Welcome, NGO!", press: () {}),
              const SizedBox(height: defaultPadding),
              Container(
                width: double.infinity,
                height: 200.0,
                color: Colors.amber[100],
                child: Center(
                  child: Image.asset(
                    'assets/images/ngoslog.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              _buildDonationStatsCard(),
              const SizedBox(height: defaultPadding),
              SectionTitle(title: "Donations Ready for Pickup", press: () {}),
              const SizedBox(height: defaultPadding / 2),
              Wrap(
                spacing: defaultPadding,
                runSpacing: defaultPadding,
                children: _donationBags.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bag = entry.value;
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 3 * defaultPadding) / 2,
                    child: RestaurantInfoBigCardNgo(
                      bagTitle: bag['title'] ?? 'Untitled Bag',
                      description: bag['description'] ?? 'No description',
                      vendorName: bag['vendor_name'] ?? 'Unknown Vendor',
                      quantity: bag['quantity_available'] ?? 0,
                      pickupStart: bag['pickup_start'] ?? 'N/A',
                      pickupEnd: bag['pickup_end'] ?? 'N/A',
                      press: () => _showAvailableItems(context, bag, index),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: defaultPadding * 2),
            ],
          ),
        ),
      ),
    );
  }
}