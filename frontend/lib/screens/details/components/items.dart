import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../components/cards/item_card.dart';
import '../../../constants.dart';
import '../../reserve/reserve_checkout.dart';

class Items extends StatefulWidget {
  final int vendorId;

  const Items({super.key, required this.vendorId});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  late Future<List<dynamic>> _mysteryBags;

  @override
  void initState() {
    super.initState();
    // Fetch the mystery bags for the given vendor when the widget is initialized
    _mysteryBags = ApiService().fetchMysteryBagsByVendor(widget.vendorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _mysteryBags, // Use the future that fetches the mystery bags
      builder: (context, snapshot) {
        // Show loading spinner while waiting for the response
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        // Handle error if there's an issue fetching the data
        else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error loading items: ${snapshot.error}"),
          );
        } 
        // Handle case where no data or an empty list is received
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No mystery bags available."),
          );
        }

        // Display a list of items (mystery bags) if data is fetched successfully
        return Column(
          children: snapshot.data!.map((bag) {
            // Convert price from string to double and handle potential null values
            final double price = double.tryParse(bag['price'].toString()) ?? 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: ItemCard(
                title: bag['title'] ?? '', // Item title
                description: bag['description'] ?? '', // Item description
                image: 'assets/images/mysterybag.png', // Placeholder image for the item
                foodType: 'Mystery Bag', // Food type (in this case, it's a mystery bag)
                price: price, // Price of the mystery bag
                priceRange: "\$" * 2, // Price range (currently just showing "$$")
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddToOrderScreen(
                      // On press, navigate to the AddToOrderScreen to place an order for the mystery bag
                      bagId: bag['id'],
                      title: bag['title'],
                      description: bag['description'],
                      price: price,
                    ),
                  ),
                ),
              ),
            );
          }).toList(), // Convert the list of bags into a list of ItemCard widgets
        );
      },
    );
  }
}
