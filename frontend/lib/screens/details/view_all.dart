import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../components/empty_state.dart';
import '../../constants.dart';
import 'components/review_card.dart';

class ViewAllReviewsScreen extends StatefulWidget {
  final dynamic vendorId;
  final String vendorName;

  const ViewAllReviewsScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<ViewAllReviewsScreen> createState() => _ViewAllReviewsScreenState();
}

class _ViewAllReviewsScreenState extends State<ViewAllReviewsScreen> {
  late Future<List<dynamic>> _reviews;
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService(); // Initialize ApiService

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      _reviews = _fetchVendorReviewsWithId(widget.vendorId);
      await _reviews;
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<dynamic>> _fetchVendorReviewsWithId(dynamic vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (token == null || refreshToken == null) {
      throw Exception('Please login to view reviews');
    }

    // First try with current token
    var response = await http.get(
      Uri.parse('${_apiService.baseUrl}/vendors/${vendorId.toString()}/reviews/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // If token expired (401), try refreshing it
    if (response.statusCode == 401) {
      final refreshResponse = await http.post(
        Uri.parse('${_apiService.baseUrl}/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (refreshResponse.statusCode == 200) {
        final newToken = jsonDecode(refreshResponse.body)['access'];
        await prefs.setString('auth_token', newToken);
        token = newToken;

        // Retry with new token
        response = await http.get(
          Uri.parse('${_apiService.baseUrl}/vendors/${vendorId.toString()}/reviews/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } else {
        throw Exception('Session expired. Please login again');
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      } else {
        throw Exception('Invalid response format');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Vendor not found');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to load reviews');
      } catch (e) {
        throw Exception('Failed to load reviews (${response.statusCode})');
      }
    }
  }

  Future<void> _refreshReviews() async {
    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.white),
            const SizedBox(width: 8.0),
            Text(
              "${widget.vendorName} Reviews",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshReviews,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReviews,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2d6a4f),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          )
              : FutureBuilder<List<dynamic>>(
            future: _reviews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const EmptyState(
                  title: "No Reviews Yet",
                  description: "This vendor hasn't received any reviews yet.",
                  icon: Icons.star_border,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final review = snapshot.data![index];
                  return ReviewCard(
                    userName: review['user_name'] ?? 'Anonymous',
                    userPhone: review['user_phone'] ?? '',
                    rating: review['rating'] ?? 0,
                    comment: review['comment'] ?? '',
                    date: review['created_at'] ?? '',
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}