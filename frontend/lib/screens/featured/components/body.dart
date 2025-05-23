import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../components/cards/big/restaurant_info_big_card.dart';
import '../../../components/scalton/big_card_scalton.dart';
import '../../../constants.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isLoading = true;
  List<dynamic> vendors = [];

  @override
  void initState() {
    super.initState();
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://sustaingobackend.onrender/api/vendors/',
        ), // Update with your actual API URL
      );

      if (response.statusCode == 200) {
        setState(() {
          vendors = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load vendors');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // You might want to show an error message to the user
      print('Error fetching vendors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: ListView.builder(
          itemCount: isLoading ? 3 : vendors.length,
          itemBuilder:
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child:
                    isLoading
                        ? const BigCardScalton()
                        : RestaurantInfoBigCard(
                          // You might need to adjust these fields based on your actual vendor data structure
                          images: [
                            vendors[index]['logo'] ?? '',
                          ], // Assuming logo is a URL
                          name: vendors[index]['name'] ?? 'Vendor',
                          rating:
                              4.3, // You might want to calculate this from reviews
                          numOfRating: 200, // Get from your reviews data
                          deliveryTime:
                              vendors[index]['delivery_time_minutes'] ?? 30,
                          foodType: const [
                            "Food",
                          ], // You might want to get this from vendor data
                          press: () {
                            // Navigate to vendor details page
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) => VendorDetailsScreen(vendor: vendors[index]),
                            // ));
                          },
                        ),
              ),
        ),
      ),
    );
  }
}
