// ✅ entry_point.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../screens/home/home_screen.dart';
import '../screens/ngodisplay/ngos.dart';
import '../screens/reservations/reservation_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../services/location_manager.dart';

class EntryPoint extends StatefulWidget {
  final int initialIndex;
  const EntryPoint({super.key, this.initialIndex = 0});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late int _selectedIndex;
  bool _locationLoaded = false;

  final List<Map<String, String>> _navItems = const [
    {"icon": "assets/icons/home.svg", "title": "Home"},
    {"icon": "assets/icons/search.svg", "title": "Search"},
    {"icon": "assets/icons/order.svg", "title": "Reservations"},
    {"icon": "assets/icons/ngo.svg", "title": "NGO"},
    {"icon": "assets/icons/profile.svg", "title": "Profile"},
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    OrderDetailsScreen(),
    NGOScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initLocation();
  }

  Future<void> _initLocation() async {
    await Future.delayed(const Duration(milliseconds: 600)); // short delay
    await LocationManager.load();
    if (LocationManager.latitude != null && LocationManager.longitude != null) {
      setState(() {
        _locationLoaded = true;
      });
    } else {
      debugPrint('[EntryPoint] ❌ Location not set');
      // Optionally show dialog or fallback UI
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: bodyTextColor,
        onTap: _onItemTapped,
        items:
            _navItems.map((item) {
              return BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  item["icon"]!,
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _navItems.indexOf(item) == _selectedIndex
                        ? primaryColor
                        : bodyTextColor,
                    BlendMode.srcIn,
                  ),
                ),
                label: item["title"]!,
              );
            }).toList(),
      ),
    );
  }
}
