import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/cards/big/restaurant_info_big_card.dart';
import '../../components/section_title.dart';
import '../../constants.dart';
import '../details/details_screen.dart';
import '../featured/featurred_screen.dart';
import 'components/medium_card_list.dart';
import 'components/promotion_banner.dart';
import '../contactus/contactus.dart';
import '../../../screens/aboutus/aboutus.dart';
import '../../../screens/faq/faqbot.dart';
import '../recipegen/recipegenerator.dart';
import '../../services/api_service.dart';
import '../../../screens/findrestaurants/find_restaurants_screen.dart';
import '../../services/location_manager.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<dynamic>> _vendors;
  int _cartItemCount = 0;
  String _deliveryLocation = '';
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _vendors = ApiService().fetchVendors();

    Future<void> _initialize() async {
      await LocationManager.load();
      final lat = LocationManager.latitude;
      final lng = LocationManager.longitude;

      if (lat != null && lng != null) {
        final allVendors = await ApiService().fetchVendors();
        final withinRadius = allVendors.where((vendor) {
          final double vendorLat = vendor['latitude'];
          final double vendorLng = vendor['longitude'];
          final double distance =
              Geolocator.distanceBetween(lat, lng, vendorLat, vendorLng) /
                  1000; // meters to km

          print(
            "📍 Distance to ${vendor['name']}: ${distance.toStringAsFixed(2)} km",
          );

          return distance <= 15;
        }).toList();

        setState(() {
          _vendors = Future.value(withinRadius);
          _deliveryLocation =
              LocationManager.currentLocation ?? 'Tap to set location';
          _isReady = true;
        });
      } else {
        setState(() => _isReady = true); // fallback
      }
    }

    Future.delayed(Duration.zero, () async {
      await LocationManager.load();
      setState(() {
        _deliveryLocation =
            LocationManager.currentLocation ?? 'Tap to set location';
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _cartItemCount = 3);
    });
  }

  Future<void> _updateDeliveryLocation() async {
    final selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const FindRestaurantsScreen()),
    );

    if (selectedLocation != null &&
        selectedLocation.trim().isNotEmpty &&
        selectedLocation.toLowerCase() != 'null' &&
        mounted) {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('savedLat');
      final lng = prefs.getDouble('savedLng');

      if (lat != null && lng != null) {
        await LocationManager.update(selectedLocation, lat: lat, lng: lng);
        setState(() {
          _deliveryLocation = selectedLocation;
        });
      } else {
        print('❗ Skipping update: lat/lng is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _vendors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('❌ HomeScreen error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Error loading vendors: ${snapshot.error}'),
            ),
          );
        }

        final vendors = snapshot.data ?? [];
        debugPrint('📦 Vendors loaded: ${vendors.length}');

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: InkWell(
                onTap: _updateDeliveryLocation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery to',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _deliveryLocation.isEmpty
                          ? "Tap to set location"
                          : _deliveryLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF2d6a4f),
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              bottom: const TabBar(
                tabs: [Tab(text: 'Restaurants'), Tab(text: 'Recipe Generator')],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.white,
              ),
            ),
            drawer: Drawer(
              backgroundColor: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF2d6a4f)),
                    accountName: const Text(
                      'SustainGo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail: const Text(
                      'Save Food, Save Money',
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: Icon(
                        Icons.restaurant_outlined,
                        size: 40,
                        color: Color(0xFF2d6a4f),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.question_answer_outlined),
                    title: const Text('FAQ Bot'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FAQBotScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat_outlined),
                    title: const Text('Contact Us'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactUsScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About Us'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutUsScreen(),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                          ),
                          child: AspectRatio(
                            aspectRatio: 3 / 1.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                "assets/images/sloganbig.PNG",
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding * 2),
                        SectionTitle(
                          title: "New on SustainGO",
                          press: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FeaturedScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        const MediumCardList(),
                        const SizedBox(height: 20),
                        const PromotionBanner(),
                        const SizedBox(height: 20),
                        SectionTitle(title: "All Restaurants", press: () {}),
                        const SizedBox(height: 16),
                        vendors.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No restaurants available at the moment.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            : Column(
                          children: vendors.map((vendor) {
                            final String logo = vendor['logo'] ?? '';
                            final String imageUrl =
                            logo.startsWith('http')
                                ? logo
                                : logo.isNotEmpty
                                ? 'https://res.cloudinary.com/di5srbmpg/$logo'
                                : 'https://via.placeholder.com/300x200.png?text=No+Image';

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                defaultPadding,
                                0,
                                defaultPadding,
                                defaultPadding,
                              ),
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
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const RecipeGeneratorScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}