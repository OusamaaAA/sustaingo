import 'package:flutter/material.dart';
import 'services/admin_api_sevice.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminApiService().fetchAllUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = AdminApiService().fetchAllUsers();
    });
  }

  void _toggleUserStatus(int userId) async {
    await AdminApiService().toggleUserActive(userId);
    _refreshUsers();
  }

  void _deleteUser(int userId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await AdminApiService().deleteUser(userId);
      _refreshUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: const Color(0xFF2d6a4f),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: PaginatedDataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Active')),
                DataColumn(label: Text('Joined')),
                DataColumn(label: Text('Actions')),
              ],
              source: _UserDataTableSource(users, _toggleUserStatus, _deleteUser),
              rowsPerPage: 10,
              columnSpacing: 16,
              showCheckboxColumn: false,
            ),
          );
        },
      ),
    );
  }
}

class _UserDataTableSource extends DataTableSource {
  final List<dynamic> users;
  final void Function(int userId) onToggle;
  final void Function(int userId) onDelete;

  _UserDataTableSource(this.users, this.onToggle, this.onDelete);

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(cells: [
      DataCell(Text(user['first_name'] ?? '')),
      DataCell(Text(user['email'] ?? '')),
      DataCell(Text(user['role'] ?? '')),
      DataCell(Icon(user['is_active'] ? Icons.check_circle : Icons.cancel, color: user['is_active'] ? Colors.green : Colors.red)),
      DataCell(Text(user['date_joined']?.substring(0, 10) ?? '')),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.sync, size: 20),
            tooltip: 'Toggle Active',
            onPressed: () => onToggle(user['id']),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, size: 20, color: Colors.red),
            tooltip: 'Delete User',
            onPressed: () => onDelete(user['id']),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
