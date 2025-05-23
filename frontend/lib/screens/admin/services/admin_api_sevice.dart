import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApiService {
  final String baseUrl = 'https://sustaingobackend.onrender.com/api';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 🔹 Admin Dashboard Stats
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin-dashboard-stats/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    }
  }

  // 🔹 Users
  Future<List<dynamic>> fetchAllUsers() async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> toggleUserActive(int userId) async {
    final token = await _getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/user/$userId/toggle-active/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to toggle user status');
    }
  }

  Future<void> deleteUser(int userId) async {
    final token = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/user/$userId/delete/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}
