// No import changes needed
import 'package:flutter/material.dart';
import '../../../components/cards/medium/restaurant_info_medium_card.dart';
import '../../../components/scalton/medium_card_scalton.dart';
import '../../../constants.dart';
import '../../details/details_screen.dart';
import '../../../services/api_service.dart';

class MediumCardList extends StatefulWidget {
  const MediumCardList({super.key});

  @override
  State<MediumCardList> createState() => _MediumCardListState();
}

class _MediumCardListState extends State<MediumCardList> {
  bool isLoading = true;
  List<dynamic> vendors = [];

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    try {
      final vendorsData = await ApiService().fetchVendors();

      vendorsData.sort((a, b) {
        final dateA = DateTime.parse(a['date_created'] ?? '1970-01-01');
        final dateB = DateTime.parse(b['date_created'] ?? '1970-01-01');
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;
      setState(() {
        vendors = vendorsData.length > 4 ? vendorsData.sublist(0, 4) : vendorsData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching vendors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 254,
          child: isLoading
              ? _buildLoadingIndicator()
              : vendors.isEmpty
                  ? const Center(child: Text('No vendors available'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = vendors[index];
                        final String logo = vendor['logo'] ?? '';
                        final String imageUrl = logo.startsWith('http')
                            ? logo
                            : logo.isNotEmpty
                                ? 'https://res.cloudinary.com/di5srbmpg/image/upload/$logo'
                                : 'https://via.placeholder.com/300x200.png?text=No+Image';

                        return Padding(
                          padding: EdgeInsets.only(
                            left: defaultPadding,
                            right: (vendors.length - 1) == index ? defaultPadding : 0,
                          ),
                          child: RestaurantInfoMediumCard(
                            image: imageUrl,
                            name: vendor['name'] ?? 'Vendor',
                            location: vendor['address'] ?? 'Location not specified',
                            delivertTime: vendor['delivery_time_minutes'] ?? 25,
                            press: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsScreen(vendor: vendor),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  SingleChildScrollView _buildLoadingIndicator() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(left: defaultPadding),
            child: MediumCardScalton(),
          ),
        ),
      ),
    );
  }
}
