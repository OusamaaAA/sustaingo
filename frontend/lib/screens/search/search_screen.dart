import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../../components/cards/big/restaurant_info_big_card.dart';
import '../../components/scalton/big_card_scalton.dart';
import '../../constants.dart';
import '../contactus/contactus.dart';
import '../../../screens/aboutus/aboutus.dart';
import '../../../screens/faq/faqbot.dart';
import '../details/details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasSearched = false;
  List<dynamic> _vendors = [];
  List<dynamic> _searchResults = [];
  String _searchQuery = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    try {
      final response = await http.get(Uri.parse('https://sustaingobackend.onrender.com/api/vendors/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _vendors = data;
        });
      } else {
        throw Exception("Failed to load vendors");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _searchQuery = query;
    });

    final results = _vendors.where((vendor) {
      final name = vendor['name']?.toLowerCase() ?? '';
      final desc = vendor['description']?.toLowerCase() ?? '';
      final match = name.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());
      return match;
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _searchResults.clear();
    });
  }

  Widget _buildResults(List<dynamic> results) {
    if (results.isEmpty) {
      return Center(
        child: Text("No results for '$_searchQuery'"),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final vendor = results[index];
        final String logo = vendor['logo'] ?? '';
                          final String imageUrl = logo.startsWith('http')
                              ? logo
                              : logo.isNotEmpty
                                  ? 'https://res.cloudinary.com/di5srbmpg/$logo'
                                  : 'https://via.placeholder.com/300x200.png?text=No+Image';

        return Padding(
          padding: const EdgeInsets.only(bottom: defaultPadding),
          child: RestaurantInfoBigCard(
  images: [vendor['logo'] ?? vendor['image_url'] ?? ''], // fallback if 'logo' is null
  name: vendor['name'],
  rating: vendor['average_rating']?.toDouble() ?? 0.0,
  numOfRating: vendor['total_reviews'] ?? 0,
  deliveryTime: vendor['delivery_time_minutes'] ?? 30,
  foodType: const ["Mystery Bag", "Rescue", "Discount"],
  press: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailsScreen(vendor: vendor),
      ),
    );
  },
),

        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: defaultPadding),
        child: BigCardScalton(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2d6a4f)),
              accountName: const Text('SustainGo', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              accountEmail: const Text('Save Food, Save Money', style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white70,
                child: Icon(Icons.restaurant_outlined, size: 40, color: Color(0xFF2d6a4f)),
              ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search restaurants...",
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            colorFilter: const ColorFilter.mode(bodyTextColor, BlendMode.srcIn),
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                      ),
                      onSubmitted: _performSearch,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d6a4f),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _performSearch(_searchController.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _isSearching
                    ? "Searching..."
                    : _hasSearched
                        ? "Results for '$_searchQuery'"
                        : "All Vendors",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isSearching
                    ? _buildLoadingShimmer()
                    : _hasSearched
                        ? _buildResults(_searchResults)
                        : _buildResults(_vendors),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
