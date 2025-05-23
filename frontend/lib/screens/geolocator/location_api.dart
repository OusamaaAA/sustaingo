import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

class LocationApi {
  static const String _baseUrl = 'https://sustaingobackend.onrender.com';

  /// Fetches user's saved locations
  static Future<List<dynamic>> getUserLocations(String authToken) async {
    final url = Uri.parse('$_baseUrl/api/user-locations/');
    final response = await http.get(url, headers: _getHeaders(authToken));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load locations: ${response.statusCode}');
    }
  }

  /// Creates a new user location
  static Future<Map<String, dynamic>> createUserLocation({
    required String name,
    required double latitude,
    required double longitude,
    required String authToken,
  }) async {
    final url = Uri.parse('$_baseUrl/api/user-locations/create/');

    final response = await http.post(
      url,
      headers: _getHeaders(authToken),
      body: json.encode({
        'name': name,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to save location: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Updates both backend and local storage
  static Future<void> updateLocation({
    required String name,
    required double latitude,
    required double longitude,
    required String authToken,
  }) async {
    try {
      // Save to backend
      final response = await createUserLocation(
        name: name,
        latitude: latitude,
        longitude: longitude,
        authToken: authToken,
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_location_name', name);
      await prefs.setDouble('savedLat', latitude);
      await prefs.setDouble('savedLng', longitude);
      await prefs.setBool('locationSet', true);

      print(
        '[LocationApi] Successfully saved location: $name ($latitude, $longitude)',
      );
      print('[LocationApi] Backend response: $response');
    } catch (e) {
      print('[LocationApi] Error saving location: $e');
      rethrow;
    }
  }

  static Map<String, String> _getHeaders(String authToken) {
    return {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };
  }
}
