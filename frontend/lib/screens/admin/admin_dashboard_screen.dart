import 'package:flutter/material.dart';
import 'components/stat_card.dart';
import 'services/admin_api_sevice.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = AdminApiService().fetchDashboardStats();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardData = AdminApiService().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF2d6a4f),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      StatCard(
                        title: 'Total Users',
                        value: data['total_users'].toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      StatCard(
                        title: 'Total Vendors',
                        value: data['total_vendors'].toString(),
                        icon: Icons.store,
                        color: Colors.orange,
                      ),
                      StatCard(
                        title: 'Total NGOs',
                        value: data['total_ngos'].toString(),
                        icon: Icons.volunteer_activism,
                        color: Colors.green,
                      ),
                      StatCard(
                        title: 'Mystery Bags',
                        value: data['total_bags'].toString(),
                        icon: Icons.shopping_bag,
                        color: Colors.purple,
                      ),
                      StatCard(
                        title: 'Reservations',
                        value: data['total_reservations'].toString(),
                        icon: Icons.receipt,
                        color: Colors.teal,
                      ),
                      StatCard(
                        title: 'Donated Bags',
                        value: data['donated_bags'].toString(),
                        icon: Icons.card_giftcard,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      drawer: Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Color(0xFF2d6a4f)),
        child: const Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      ListTile(
        leading: Icon(Icons.people),
        title: const Text('Manage Users'),
        onTap: () {
          Navigator.pushNamed(context, '/admin/users');
        },
      ),
      // You’ll add more tiles later (NGOs, Vendors, etc.)
    ],
  ),
),

    );
  }
}