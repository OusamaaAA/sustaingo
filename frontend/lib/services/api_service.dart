import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://sustaingobackend.onrender.com/api';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      print('🔴 No refresh token found.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      print('🔁 Refresh token response: ${response.statusCode}');
      print('🧾 Body: ${response.body}');

      if (response.statusCode == 200) {
        final newAccess = jsonDecode(response.body)['access'];
        await prefs.setString('auth_token', newAccess);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("🔴 Error during token refresh: $e");
      return false;
    }
  }

  Future<http.Response> _authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    String? token = await _getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');

    // 🔽 MODIFIED: Allow null token and handle it correctly
    Map<String, String> buildHeaders(String? token) {
      final headers = {
        'Content-Type': 'application/json',
      }; // Start with default headers
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return headers;
    }

    Map<String, String> headers = buildHeaders(token);

    print('🔗 Request: $method $endpoint');
    if (body != null) print('📤 Body: $body');

    http.Response response = await _makeRequest(method, url, headers, body);

    if (response.statusCode == 401) {
      print('🔄 Token expired, refreshing...');
      bool refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await _getAccessToken();
        if (newToken != null) {
          // MODIFIED: Check for null after refresh
          headers = buildHeaders(newToken);
          response = await _makeRequest(method, url, headers, body);
        } else {
          throw Exception('Failed to refresh token. Session expired.');
        }
      } else {
        throw Exception('Session expired. Please log in again.');
      }
    }

    return response;
  }

  Future<http.Response> _makeRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    switch (method) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(url, headers: headers, body: jsonEncode(body));
      case 'PATCH':
        return await http.patch(url, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  Future<List<dynamic>> fetchVendors() async {
    final response = await _authenticatedRequest('GET', '/vendors/');
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> fetchMysteryBagsByVendor(int vendorId) async {
    final response = await _authenticatedRequest(
      'GET',
      '/vendors/$vendorId/bags/',
    );
    return jsonDecode(response.body);
  }

  Future<bool> reserveBag(int bagId) async {
    final token = await _getAccessToken();
    print("🛡️ Sending reservation with token: $token");

    final response = await _authenticatedRequest(
      'POST',
      '/bags/$bagId/reserve/',
    );
    print("🔁 Reservation response: ${response.statusCode}");
    print("📥 Body: ${response.body}");

    return response.statusCode == 201;
  }

  Future<List<dynamic>> fetchVendorBags() async {
    final response = await _authenticatedRequest('GET', '/vendor-my-bags/');
    return jsonDecode(response.body);
  }

  Future<bool> createMysteryBag({
    required String title,
    required String description,
    required String hiddenContents,
    required double price,
    required int quantity,
    required String pickupStart,
    required String pickupEnd,
    required bool isDonation,
  }) async {
    final response = await _authenticatedRequest(
      'POST',
      '/bags/create/',
      body: {
        'title': title,
        'description': description,
        'hidden_contents': hiddenContents,
        'price': price,
        'quantity_available': quantity,
        'pickup_start': pickupStart,
        'pickup_end': pickupEnd,
        'is_donation': isDonation,
      },
    );

    // ✅ Debug lines added below:
    print('📤 Create Mystery Bag status: ${response.statusCode}');
    print('🧾 Create Mystery Bag response: ${response.body}');

    return response.statusCode == 201;
  }

  Future<bool> updateMysteryBag({
    required int bagId,
    required String title,
    required String description,
    required String hiddenContents,
    required double price,
    required int quantity,
    required String pickupStart,
    required String pickupEnd,
    required bool isDonation,
  }) async {
    final response = await _authenticatedRequest(
      'PATCH',
      '/bags/$bagId/update/',
      body: {
        'title': title,
        'description': description,
        'hidden_contents': hiddenContents,
        'price': price,
        'quantity_available': quantity,
        'pickup_start': pickupStart,
        'pickup_end': pickupEnd,
        'is_donation': isDonation,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteMysteryBag(int bagId) async {
    final response = await _authenticatedRequest(
      'DELETE',
      '/bags/$bagId/delete/',
    );
    return response.statusCode == 204;
  }

  Future<List<dynamic>> fetchVendorReservations() async {
    final response = await _authenticatedRequest(
      'GET',
      '/vendor-reservations/',
    );
    return jsonDecode(response.body);
  }

  Future<bool> markReservationAsCollected(int reservationId) async {
    final response = await _authenticatedRequest(
      'PATCH',
      '/reservations/$reservationId/collected/',
    );
    return response.statusCode == 200;
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    final response = await _authenticatedRequest(
      'PATCH',
      '/profile/update/',  // This matches your Django URL pattern
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> updateVendorProfile({
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required bool deliveryAvailable,
    required int deliveryTimeMinutes,
  }) async {
    final response = await _authenticatedRequest(
      'PATCH',
      '/vendor-profile/update/',
      body: {
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'delivery_available': deliveryAvailable,
        'delivery_time_minutes': deliveryTimeMinutes,
      },
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> fetchVendorProfile() async {
    final response = await _authenticatedRequest('GET', '/vendor-profile/');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<List<dynamic>> fetchAvailableDonations() async {
    final response = await _authenticatedRequest(
      'GET',
      '/available-donations/',
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchVendorDashboardSummary() async {
    final response = await _authenticatedRequest(
      'GET',
      '/vendor-dashboard-summary/',
    );
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<List<dynamic>> fetchVendorReviews() async {
    final response = await _authenticatedRequest('GET', '/vendor-reviews/');
    return jsonDecode(response.body);
  }
}
