import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String userPhone;
  final int rating;
  final String comment;
  final String date;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.userPhone,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date if it's not empty
    String formattedDate = '';
    if (date.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(date); // Attempt to parse the date string
        formattedDate = DateFormat('MMM d, y').format(parsedDate); // Format the date in 'MMM d, y' format
      } catch (e) {
        formattedDate = date; // If parsing fails, use the original date string
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the review card
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Light shadow effect
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2d6a4f).withOpacity(0.2), // Background color of the avatar
                    borderRadius: BorderRadius.circular(20), // Make the avatar circular
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?', // Display the first letter of the user's name
                      style: const TextStyle(
                        color: Color(0xFF2d6a4f), // Avatar text color
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // User Info and Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // User's name style
                        ),
                      ),
                      if (userPhone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            userPhone, // Display the user's phone number if it's not empty
                            style: const TextStyle(
                              color: Colors.grey, // Phone number color
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Star Rating
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1), // Background color of the rating container
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16), // Star icon
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(), // Display the rating
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Rating text style
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Review Comment
            if (comment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  comment, // Display the comment if it's not empty
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4, // Line height for better readability
                  ),
                ),
              ),

            // Date
            if (formattedDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  formattedDate, // Display the formatted date
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600, // Date text color
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
