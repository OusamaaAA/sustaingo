import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import '../contactus/contactus.dart';
import '../../../screens/aboutus/aboutus.dart';
import '../../../screens/faq/faqbot.dart';

/// The screen displaying a list of supporting NGOs with their contact information.
class NGOScreen extends StatefulWidget {
  final String? currentDeliveryLocation;

  const NGOScreen({super.key, this.currentDeliveryLocation});

  @override
  State<NGOScreen> createState() => _NGOScreenState();
}

class _NGOScreenState extends State<NGOScreen> {
  // List to hold fetched NGO data
  List<dynamic> _ngos = [];

  // Loading state
  bool _isLoading = true;

  // Error message for UI display
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchNGOs(); // Fetch NGO data when the screen initializes
  }

  /// Fetches the list of public NGOs from the backend
  Future<void> fetchNGOs() async {
    try {
      final response = await http.get(
        Uri.parse('https://sustaingobackend.onrender.com/api/public_ngos/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            _ngos = data;
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load NGOs');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Opens an external URL using the device browser or app
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Builds an individual NGO card widget displaying its details and action buttons
  Widget _buildNGOCard(BuildContext context, Map<String, dynamic> ngo) {
    final String organizationName = ngo['organization_name'] ?? 'Unknown NGO';
    final String region = ngo['region'] ?? 'No region provided';
    final String description = ngo['description'] ?? '';
    final String? email = ngo['email'];
    final String? website = ngo['website'];

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            Theme.of(context).colorScheme.secondary.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NGO image and name/region section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NGO Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: ngo['logo'] != null && ngo['logo'].toString().isNotEmpty
                          ? NetworkImage('https://res.cloudinary.com/di5srbmpg/${ngo['logo']}')
                          : const AssetImage('assets/images/placeholder_ngo.jpg') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // NGO Name and Region
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organizationName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // NGO Description if available
            if (description.isNotEmpty)
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            // Buttons for email and website (if provided)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (email != null && email.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL('mailto:$email'),
                        icon: const Icon(Icons.email, size: 16, color: Colors.white),
                        label: const Text("Email", style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                if (website != null && website.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL(website),
                        icon: const Icon(Icons.web, size: 16, color: Colors.white),
                        label: const Text("Website", style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar with rounded bottom
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Opens side drawer
              },
            );
          },
        ),
        title: const Text(
          "Supporting NGOs",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header with app name and icon
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2d6a4f)),
              accountName: const Text(
                'SustainGo',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text(
                'Save Food, Save Money',
                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white70,
                child: Icon(Icons.restaurant_outlined, size: 40, color: Color(0xFF2d6a4f)),
              ),
            ),
            // Navigation drawer options
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
      body: SafeArea(
        // Main body with either loading spinner, error, or NGO list
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _ngos.isEmpty
                ? const Center(child: Text("No NGOs available at the moment."))
                : ListView.builder(
                    itemCount: _ngos.length,
                    itemBuilder: (context, index) => _buildNGOCard(context, _ngos[index]),
                  ),
      ),
    );
  }
}
