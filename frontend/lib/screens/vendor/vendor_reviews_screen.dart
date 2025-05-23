import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates nicely
import '../../services/api_service.dart';
import '../../components/empty_state.dart';

class VendorReviewsScreen extends StatefulWidget {
  const VendorReviewsScreen({super.key});

  @override
  State<VendorReviewsScreen> createState() => _VendorReviewsScreenState();
}

class _VendorReviewsScreenState extends State<VendorReviewsScreen> {
  late Future<List<dynamic>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = ApiService().fetchVendorReviews();
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviews = ApiService().fetchVendorReviews();
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Reviews", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF2d6a4f), // Keeping the original app bar color
        elevation: 1, // Subtle shadow
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100], // Light, neutral background
      body: RefreshIndicator(
        onRefresh: _refreshReviews,
        color: const Color(0xFF2d6a4f), // Keeping the original accent color
        child: FutureBuilder<List<dynamic>>(
          future: _reviews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2d6a4f))); // Keeping the original accent color
            } else if (snapshot.hasError) {
              return Center(child: Text('Oops! Could not load reviews.', style: TextStyle(color: Colors.red[400])));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyState(
                title: "No Feedback Yet",
                description: "Once customers leave reviews, they'll appear here.",
                icon: Icons.chat_bubble_outline,
              );
            }

            final reviews = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF81c14b), // A lighter shade of the primary green
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.person_outline),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['user_name'] ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (review['user_phone'] != null && review['user_phone'].isNotEmpty)
                                    Text(
                                      review['user_phone'],
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(
                                5,
                                    (starIndex) => Icon(
                                  starIndex < (review['rating'] ?? 0)
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: Colors.amber[400],
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review['comment'] ?? 'No comment provided.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            _formatDate(review['created_at']),
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}