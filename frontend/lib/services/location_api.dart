import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationApi {
  /// Sends the chosen latitude/longitude to your Django backend.
  static Future<void> saveLocation({
    required double latitude,
    required double longitude,
    required String authToken,
  }) async {
    final uri = Uri.https(
      'sustaingobackend.onrender.com',
      '/api/user/location/',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to save location (${response.statusCode}): ${response.body}',
      );
    }
  }
}
