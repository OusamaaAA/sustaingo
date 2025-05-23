import 'package:flutter/material.dart';
import '../auth/sign_in_screen.dart';
import '../../services/api_service.dart';
import '../../components/empty_state.dart';
import 'package:shimmer/shimmer.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  late Future<Map<String, dynamic>> _dashboardData;
  String? _errorMessage;
  late Future<List<dynamic>> _recentReservations;

  final ApiService _apiService = ApiService(); // Create an instance of ApiService

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadRecentReservations();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _dashboardData = _fetchDashboardSafe();
    });
  }

  Future<void> _loadRecentReservations() async {
    setState(() {
      _recentReservations = _fetchRecentReservationsSafe();
    });
  }

  Future<List<dynamic>> _fetchRecentReservationsSafe() async {
    try {
      final reservations = await _apiService.fetchVendorReservations();
      // Sort by reserved_at in descending order (most recent first)
      reservations.sort((a, b) {
        final aTime = DateTime.parse(a['reserved_at']);
        final bTime = DateTime.parse(b['reserved_at']);
        return bTime.compareTo(aTime);
      });
      return reservations.take(3).toList();
    } catch (e) {
      print('🔴 Error fetching recent reservations: $e');
      // Show error message to the user in the UI.
      setState(() {
        _errorMessage = 'Failed to load recent reservations: $e';
      });
      return [];
    }
  }

  Future<Map<String, dynamic>> _fetchDashboardSafe() async {
    try {
      final data = await _apiService.fetchVendorDashboardSummary();
      _errorMessage = null;
      return data;
    } catch (e) {
      print('🔴 VendorDashboard Error: $e');
      if (e.toString().contains('Session expired')) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
              (_) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to load dashboard: $e';
        });
      }
      return {};
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
    await _loadRecentReservations();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (_errorMessage != null) {
                  return Center(child: Text(_errorMessage!));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingShimmer();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Unexpected error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyState(
                    title: 'No Dashboard Data',
                    description: 'Once you have some activity, your dashboard will show key metrics here.',
                    icon: Icons.insert_chart_outlined,
                  );
                }

                final data = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildInfoCard(title: 'Total Bags', value: data['total_bags'].toString(), icon: Icons.inventory)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoCard(title: 'Reservations', value: data['total_reservations'].toString(), icon: Icons.bookmark_border)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoCard(title: 'Collected', value: data['collected_reservations'].toString(), icon: Icons.check_circle_outline)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoCard(title: 'Collection Rate', value: '${data['collected_percentage']}%', icon: Icons.trending_up)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Reservations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: _recentReservations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading recent reservations: ${snapshot.error}'));
                }
                else if (_errorMessage != null) { // Display the error message
                  return Center(child: Text(_errorMessage!));
                }
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No recent reservations.');
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final reservation = snapshot.data![index];
                      final bagTitle = reservation['bag_title'] ?? 'N/A';
                      final customerName = reservation['user_name'] ?? 'N/A';
                      final reservedAt = reservation['reserved_at'] != null
                          ? DateTime.parse(reservation['reserved_at']).toLocal().toString().split(' ')[0]
                          : 'N/A';
                      final reservationId = reservation['reservation_id']?.toString() ?? 'N/A';

                      return ListTile(
                        leading: const Icon(Icons.bookmark_outline),
                        title: Text('$bagTitle (ID: $reservationId)'),
                        subtitle: Text('Customer: $customerName - Reserved on: $reservedAt'),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required IconData icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildShimmerCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

