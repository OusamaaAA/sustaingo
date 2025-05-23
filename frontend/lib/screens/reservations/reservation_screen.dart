import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import '../../components/buttons/primary_button.dart';
import '../auth/components/auth_helper.dart';
import '../recipegen/recipegenerator.dart';
import '../../../screens/aboutus/aboutus.dart';
import '../../../screens/contactus/contactus.dart';
import '../../../screens/faq/faqbot.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await getValidAccessToken();

      if (token == null) {
        setState(() {
          _errorMessage = "Session expired. Please log in again.";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://sustaingobackend.onrender.com/api/my-reservations/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _reservations = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load reservations.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
        _isLoading = false;
      });
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied surprise items!')),
    );
  }

  Widget buildReservationCard(dynamic res) {
    final isCollected = res['is_collected'];
    final reservedAt = DateFormat.yMMMd().add_jm().format(DateTime.parse(res['reserved_at']));
    final payment = res['payment_method']
        .toString()
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
    final surpriseItems = res['contents_revealed'] ?? '';
    final hasHidden = surpriseItems.toString().trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isCollected ? Colors.white : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(res['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(res['description']),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Vendor: ${res['vendor'] ?? 'N/A'}"),
                  Text("Reserved at: $reservedAt"),
                  Text("Payment: $payment"),
                  if (res['price_paid'] != '0.0') Text("Paid: \$${res['price_paid']}")
                ]),
                Column(
                  children: [
                    Icon(
                      isCollected ? Icons.check_circle : Icons.timelapse,
                      color: isCollected ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    Text(
                      isCollected ? "Collected" : "Pending",
                      style: TextStyle(color: isCollected ? Colors.green : Colors.orange),
                    )
                  ],
                )
              ],
            ),
            if (hasHidden) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("🎁 Surprise Inside:", style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: "Copy",
                    onPressed: () => copyToClipboard(surpriseItems),
                  )
                ],
              ),
              Text(surpriseItems, style: const TextStyle(color: Colors.black87)),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text("Your Reservations",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          backgroundColor: const Color(0xFF2d6a4f),
          elevation: 4,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF2d6a4f)),
                accountName: Text("SustainGo",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                accountEmail: Text("Save Food, Save Money",
                    style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: Icon(Icons.restaurant, size: 40, color: Color(0xFF2d6a4f))),
              ),
              ListTile(
                leading: const Icon(Icons.question_answer_outlined),
                title: const Text('FAQ Bot'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQBotScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text('Contact Us'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Us'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
              ),
              const Divider(color: Colors.grey),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SafeArea(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _reservations.isEmpty
                          ? const Center(child: Text("No reservations found"))
                          : ListView.builder(
                              itemCount: _reservations.length,
                              itemBuilder: (context, index) => buildReservationCard(_reservations[index]),
                            ),
            ),
            const RecipeGeneratorScreen(),
          ],
        ),
      ),
    );
  }
}