import 'package:shared_preferences/shared_preferences.dart';
import 'location_api.dart';

class LocationManager {
  static String? currentLocation;
  static double? latitude;
  static double? longitude;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    currentLocation = prefs.getString('user_location_name');
    latitude = prefs.getDouble('savedLat');
    longitude = prefs.getDouble('savedLng');
    print('[LocationManager] Loaded: $currentLocation ($latitude, $longitude)');
  }

  static Future<void> update(
    String name, {
    required double? lat,
    required double? lng,
    String? authToken,
  }) async {
    if (lat == null || lng == null) {
      print('[LocationManager] ❌ Skipping update due to null lat/lng');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_location_name', name);
    await prefs.setDouble('savedLat', lat);
    await prefs.setDouble('savedLng', lng);
    await prefs.setBool('locationSet', true);

    currentLocation = name;
    latitude = lat;
    longitude = lng;

    // Save to backend if authToken is provided
    if (authToken != null) {
      try {
        await LocationApi.saveLocation(
          latitude: lat,
          longitude: lng,
          authToken: authToken,
        );
      } catch (e) {
        print('[LocationManager] Error saving to backend: $e');
        // You might want to retry or handle this error
      }
    }

    print('[LocationManager] ✅ Updated to: $name ($lat, $lng)');
  }
}
