import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart';
import '../../../components/price_range_and_food_type.dart';
import '../../../components/rating_with_counter.dart';
import '../../../constants.dart';
import '../view_all.dart';
import 'review_card.dart';

class RestaurantInfo extends StatefulWidget {
  final Map<String, dynamic> vendor;

  const RestaurantInfo({super.key, required this.vendor});

  @override
  State<RestaurantInfo> createState() => _RestaurantInfoState();
}

class _RestaurantInfoState extends State<RestaurantInfo> {
  List<dynamic> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadShuffledReviews();
  }

  Future<void> _loadShuffledReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('${ApiService().baseUrl}/vendors/${widget.vendor['id']}/reviews/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          // Shuffle and take first 2 reviews
          final shuffled = List.from(data)..shuffle();
          setState(() {
            _reviews = shuffled.take(2).toList();
            _loadingReviews = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _loadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.vendor['name'] ?? 'Vendor Name',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: defaultPadding / 2),
          const PriceRangeAndFoodtype(
            foodType: ["Mystery Bag"],
          ),
          const SizedBox(height: defaultPadding / 2),
          RatingWithCounter(
            rating: widget.vendor['average_rating']?.toDouble() ?? 0.0,
            numOfRating: 200,
          ),
          const SizedBox(height: defaultPadding),
          Row(
            children: [
              DeliveryInfo(
                iconSrc: "assets/icons/delivery.svg",
                text: widget.vendor['delivery_available'] == true ? "Free" : "Not Available",
                subText: "Delivery",
                iconColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: defaultPadding),
              DeliveryInfo(
                iconSrc: "assets/icons/clock.svg",
                text: "${widget.vendor['delivery_time_minutes']}",
                subText: "Minutes",
                iconColor: theme.colorScheme.secondary,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () async {
                  final phoneNumber = widget.vendor['phone_number'] ?? '';
                  if (phoneNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Phone number not available")),
                    );
                    return;
                  }

                  final url = Uri.parse('tel:$phoneNumber');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Could not launch phone app")),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text("Call", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding * 2),
          Text(
            "Customer Reviews",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: defaultPadding),

          // Reviews Section
          _loadingReviews
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
              ? const Text(
            "No reviews yet",
            style: TextStyle(color: Colors.grey),
          )
              : Column(
            children: _reviews
                .map((review) => ReviewCard(
              userName: (review['user_name']?.toString().trim().isNotEmpty ?? false)
                  ? review['user_name']
                  : 'Customer',

              userPhone: review['user_phone'] ?? '',
              rating: review['rating'] ?? 0,
              comment: review['comment'] ?? '',
              date: review['created_at'] ?? '',
            ))
                .toList(),
          ),

          if (_reviews.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAllReviewsScreen(
                          vendorId: widget.vendor['id'],
                          vendorName: widget.vendor['name'] ?? 'Restaurant',
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: const Color(0xFF2d6a4f).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View All Reviews",
                        style: TextStyle(
                          color: Color(0xFF2d6a4f),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF2d6a4f),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return _buildAddReviewBottomSheet(context);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Add a Review", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }

  Widget _buildAddReviewBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    double _rating = 0;
    final TextEditingController _reviewController = TextEditingController();

    Future<void> _submitReview() async {
      if (_rating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a rating")),
        );
        return;
      }

      if (_reviewController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please write your review")),
        );
        return;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final refreshToken = prefs.getString('refresh_token');

        if (token == null || refreshToken == null) {
          throw Exception('Please login to submit a review');
        }

        // First attempt with current token
        var response = await http.post(
          Uri.parse('${ApiService().baseUrl}/vendors/${widget.vendor['id']}/reviews/create/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'rating': _rating,
            'comment': _reviewController.text,
          }),
        );

        // If token expired (401), try refreshing it
        if (response.statusCode == 401) {
          final refreshResponse = await http.post(
            Uri.parse('${ApiService().baseUrl}/api/token/refresh/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          );

          if (refreshResponse.statusCode == 200) {
            final newToken = jsonDecode(refreshResponse.body)['access'];
            await prefs.setString('auth_token', newToken);

            // Retry with new token
            response = await http.post(
              Uri.parse('${ApiService().baseUrl}/vendors/${widget.vendor['id']}/reviews/create/'),
              headers: {
                'Authorization': 'Bearer $newToken',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'rating': _rating,
                'comment': _reviewController.text,
              }),
            );
          } else {
            throw Exception('Session expired. Please login again');
          }
        }

        if (response.statusCode == 201) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Review submitted successfully!")),
          );
          // Refresh reviews after submission
          _loadShuffledReviews();
        } else {
          throw Exception('Failed to submit review: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting review: ${e.toString()}")),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: defaultPadding,
        right: defaultPadding,
        top: defaultPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Write a Review", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: defaultPadding),
          Text("Rating:", style: theme.textTheme.titleMedium),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star_rounded,
              color: Colors.amber.shade400,
            ),
            onRatingUpdate: (rating) {
              _rating = rating;
            },
          ),
          const SizedBox(height: defaultPadding),
          Text("Your Review:", style: theme.textTheme.titleMedium),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: "Share your experience...",
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReview, // Updated to use our submit function
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Submit Review", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}

class DeliveryInfo extends StatelessWidget {
  const DeliveryInfo({
    super.key,
    required this.iconSrc,
    required this.text,
    required this.subText,
    required this.iconColor,
  });

  final String iconSrc, text, subText;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconSrc,
          height: 22,
          width: 22,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            text: text,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            children: [
              TextSpan(
                text: "\n$subText",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              )
            ],
          ),
        ),
      ],
    );
  }
}