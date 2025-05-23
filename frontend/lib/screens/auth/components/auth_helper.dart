import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getValidAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('refresh_token');

  if (refreshToken == null) {
    print('🔴 No refresh token found');
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('https://sustaingobackend.onrender.com/api/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    print('🔁 Refresh response code: ${response.statusCode}');
    print('🔁 Refresh response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];
      await prefs.setString('auth_token', newAccessToken);
      return newAccessToken;
    } else {
      // ✅ Do not clear session here — let UI decide
      return null;
    }
  } catch (e) {
    print("🔴 Token refresh error: $e");
    return null;
  }
}

