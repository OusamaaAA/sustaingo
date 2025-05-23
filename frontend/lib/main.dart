import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'services/location_manager.dart';
import 'entry_point.dart';
import 'screens/vendor/vendor_home_screen.dart';
import 'screens/ngo/ngo_home_screen.dart';
import 'screens/deliv/deliv_home_screen.dart';
import 'screens/onboarding/onboarding_scrreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationManager.load();
  print('[main.dart] Location loaded: ${LocationManager.currentLocation}');
  runApp(const AppLoader());
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  String? _token;
  String? _role;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('role');

    setState(() {
      _token = token;
      _role = role;
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MyApp(token: _token, role: _role);
  }
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? role;

  const MyApp({super.key, required this.token, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SustainGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: GoogleFonts.openSansTextTheme(
          const TextTheme(
            bodyMedium: TextStyle(color: bodyTextColor),
            bodySmall: TextStyle(color: bodyTextColor),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.all(defaultPadding),
          hintStyle: TextStyle(color: bodyTextColor),
        ),
      ),
      home: _getHomeScreen(),
    );
  }

  Widget _getHomeScreen() {
    if (token != null && role != null) {
      switch (role) {
        case 'vendor':
          return const VendorHomeScreen();
        case 'ngo':
          return const NGOHomeScreen();
        case 'deliveryguy':
          return const DelivHomeScreen();
        default:
          return const EntryPoint();
      }
    } else {
      return const OnboardingScreen();
    }
  }
}
