import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_mystery_bag_screen.dart';

class MyBagsScreen extends StatefulWidget {
  const MyBagsScreen({super.key});

  @override
  State<MyBagsScreen> createState() => _MyBagsScreenState();
}

class _MyBagsScreenState extends State<MyBagsScreen> {
  late Future<List<dynamic>> _vendorBags;
  final Color _primaryColor = const Color(0xFF2d6a4f);
  final Color _accentColor = const Color(0xFF52b788);

  @override
  void initState() {
    super.initState();
    _loadBags();
  }

  Future<void> _loadBags() async {
    setState(() {
      _vendorBags = ApiService().fetchVendorBags();
    });
  }

  Map<String, dynamic> _getDefaultBag() {
    return {
      'title': '',
      'description': '',
      'hidden_contents': '',
      'price': 0.0,
      'quantity_available': 1,
      'pickup_start': '00:00',
      'pickup_end': '00:00',
      'is_donation': false,
    };
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '\$0.00';
    final numValue = price is String ? double.tryParse(price) ?? 0.0 : price;
    return '\$${numValue.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Mystery Bags",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _vendorBags,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final bags = snapshot.data!;
          return RefreshIndicator(
            color: _primaryColor,
            backgroundColor: Colors.white,
            onRefresh: _loadBags,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bags.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bag = bags[index];
                return _buildBagCard(bag, context);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create_bag_fab',
        onPressed: () {
          final newBag = _getDefaultBag();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditMysteryBagScreen(bag: newBag),
            ),
          ).then((_) => _loadBags());
        },
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBagCard(Map<String, dynamic> bag, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMysteryBagScreen(
              bag: {
                'id': bag['id'],
                'title': bag['title'] ?? '',
                'description': bag['description'] ?? '',
                'hidden_contents': bag['hidden_contents'] ?? '',
                'price': bag['price'] ?? 0.0,
                'quantity_available': bag['quantity_available'] ?? 1,
                'pickup_start': bag['pickup_start'] ?? '00:00',
                'pickup_end': bag['pickup_end'] ?? '00:00',
                'is_donation': bag['is_donation'] ?? false,
              },
            ),
          ),
        ).then((_) => _loadBags());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  image: bag['image'] != null
                      ? DecorationImage(
                    image: NetworkImage(bag['image']),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: bag['image'] == null
                    ? Icon(Icons.shopping_bag, color: _primaryColor.withOpacity(0.6))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bag['title'] ?? 'Untitled Bag',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bag['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatPrice(bag['price']),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _primaryColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${bag['quantity_available'] ?? '0'} in stock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading your bags...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBags,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Mystery Bags Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first mystery bag to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newBag = _getDefaultBag();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMysteryBagScreen(bag: newBag),
                  ),
                ).then((_) => _loadBags());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Create First Bag',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}