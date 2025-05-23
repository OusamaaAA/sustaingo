import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VendorReservationsScreen extends StatefulWidget {
  const VendorReservationsScreen({super.key});

  @override
  State<VendorReservationsScreen> createState() => _VendorReservationsScreenState();
}

class _VendorReservationsScreenState extends State<VendorReservationsScreen> {
  // Future to hold vendor reservations data
  late Future<List<dynamic>> _reservations;

  @override
  void initState() {
    super.initState();
    // Initialize the reservations by fetching data from the API
    _reservations = ApiService().fetchVendorReservations();
  }

  // Refresh function to fetch updated reservations
  Future<void> _refreshReservations() async {
    setState(() {
      // Reload reservations data from API
      _reservations = ApiService().fetchVendorReservations();
    });
  }

  // Mark a reservation as collected
  Future<void> _markCollected(int reservationId) async {
    bool success = await ApiService().markReservationAsCollected(reservationId);
    // Show success message if reservation is marked as collected
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as Collected!')),
      );
      _refreshReservations();  // Refresh the list of reservations
    } else {
      // Show error message if marking as collected failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark as collected.')),
      );
    }
  }

  // Build the reservation content widget
  Widget _buildReservationContent() {
    return FutureBuilder<List<dynamic>>(
      future: _reservations,  // Fetch reservations
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        // Handle error state
        else if (snapshot.hasError) {
          return Center(child: Text('Error loading reservations: ${snapshot.error}'));
        } 
        // Handle empty data state
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No reservations yet.'));
        }

        final reservations = snapshot.data!;  // Reservations data

        // List of reservations with pull-to-refresh
        return RefreshIndicator(
          onRefresh: _refreshReservations,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,  // Number of reservations
            itemBuilder: (context, index) {
              final reservation = reservations[index];  // Reservation details
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Color(0xFF2d6a4f)),
                  title: Text(reservation['bag_title'] ?? 'Mystery Bag'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reserved by: ${reservation['user_name'] ?? 'User'}'),
                      Text('Reserved at: ${reservation['reserved_at'] ?? ''}'),
                      Text('Status: ${reservation['is_collected'] ? 'Collected' : 'Pending'}'),
                    ],
                  ),
                  trailing: reservation['is_collected']
                      // Show check icon if collected, otherwise show button to mark as collected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : TextButton(
                          onPressed: () => _markCollected(reservation['reservation_id']),
                          child: const Text('Mark Collected'),
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and custom styling
      appBar: AppBar(
        title: const Text("Vendor Reservations", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildReservationContent(),  // Display reservation content
    );
  }
}
