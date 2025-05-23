import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../../screens/auth/sign_in_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  String name = '';
  String description = '';
  String address = '';
  String? latitude;
  String? longitude;
  int deliveryTimeMinutes = 0;
  bool _isEditing = false;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _deliveryTimeController;
  String? _updateErrorMessage;

  void _discardChanges() {
    setState(() {
      _nameController.text = name;
      _descriptionController.text = description;
      _addressController.text = address;
      _deliveryTimeController.text = deliveryTimeMinutes.toString();
      _isEditing = false;
      _updateErrorMessage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _deliveryTimeController = TextEditingController();
    _fetchVendorProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendorProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('Fetching profile with token: $token');

      final response = await http.get(
        Uri.parse('https://sustaingobackend.onrender.com/api/vendor-profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'] ?? '';
          description = data['description'] ?? '';
          address = data['address'] ?? '';
          latitude = data['latitude']?.toString();
          longitude = data['longitude']?.toString();
          deliveryTimeMinutes = data['delivery_time_minutes'] ?? 0;

          _nameController.text = name;
          _descriptionController.text = description;
          _addressController.text = address;
          _deliveryTimeController.text = deliveryTimeMinutes.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _updateErrorMessage = 'Failed to load profile data: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        _isLoading = false;
        _updateErrorMessage = 'Error connecting to server: $e';
      });
    }
  }

  Future<void> _updateVendorProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _updateErrorMessage = null;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token == null) {
          setState(() {
            _updateErrorMessage = 'Authentication token is missing!';
            _isLoading = false;
          });
          return;
        }

        var request = http.MultipartRequest(
          'PATCH',
          Uri.parse('https://sustaingobackend.onrender.com/api/vendor-profile/update/'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = _nameController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['address'] = _addressController.text;
        request.fields['delivery_time_minutes'] = _deliveryTimeController.text;

        if (latitude != null && latitude!.isNotEmpty) {
          request.fields['latitude'] = latitude!;
        }
        if (longitude != null && longitude!.isNotEmpty) {
          request.fields['longitude'] = longitude!;
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: $responseBody');

        if (response.statusCode == 200) {
          final data = json.decode(responseBody);
          setState(() {
            name = data['name'] ?? _nameController.text;
            description = data['description'] ?? _descriptionController.text;
            address = data['address'] ?? _addressController.text;
            deliveryTimeMinutes = data['delivery_time_minutes'] ?? int.tryParse(_deliveryTimeController.text) ?? 0;
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        } else {
          setState(() {
            _updateErrorMessage = 'Failed to update profile (Status ${response.statusCode}): $responseBody';
          });
        }
      } catch (e) {
        setState(() {
          _updateErrorMessage = 'Error updating profile: ${e.toString()}';
        });
        debugPrint('Error updating profile: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('role');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: AppBar(
        title: const Text("Vendor Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    backgroundColor: const Color(0xFF2d6a4f),
    elevation: 2,
    shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Form(
    key: _formKey,
    child: Stack(
    children: [
    SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const SizedBox(height: defaultPadding * 1.5),
    Center(
    child: Column(
    children: [
    CircleAvatar(
    radius: 40,
    backgroundColor: const Color(0xFF2d6a4f),
    child: const Icon(Icons.store, size: 40, color: Colors.white),
    ),
    const SizedBox(height: 16),
    Text(
    _isEditing ? 'Edit Vendor Profile' : name,
    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    ],
    ),
    ),
    const SizedBox(height: defaultPadding),

    // Name Field
    ModernProfileTaskCard(
    svgSrc: "assets/icons/profile.svg",
    title: "Business Name",
    subTitle: _isEditing ? null : name,
    color: const Color(0xFF60A917),
    child: _isEditing
    ? TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(labelText: 'Business Name'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your business name';
    }
    return null;
    },
    )
        : null,
    ),

    // Description Field
    ModernProfileTaskCard(
    svgSrc: "assets/icons/description.svg",
    title: "Description",
    subTitle: _isEditing ? null : description.isNotEmpty ? description : 'No description provided',
    color: const Color(0xFF3498DB),
    child: _isEditing
    ? TextFormField(
    controller: _descriptionController,
    decoration: const InputDecoration(labelText: 'Description'),
    maxLines: 3,
    )
        : null,
    ),

    // Address Field
    ModernProfileTaskCard(
    svgSrc: "assets/icons/marker.svg",
    title: "Address",
    subTitle: _isEditing ? null : address.isNotEmpty ? address : 'No address provided',
    color: const Color(0xFF9B59B6),
    child: _isEditing
    ? TextFormField(
    controller: _addressController,
    decoration: const InputDecoration(labelText: 'Address'),
    )
        : null,
    ),

    // Delivery Time
    ModernProfileTaskCard(
    svgSrc: "assets/icons/clock.svg",
    title: "Delivery Time (minutes)",
    subTitle: _isEditing ? null : deliveryTimeMinutes.toString(),
    color: const Color(0xFF3498DB),
    child: _isEditing
    ? TextFormField(
    controller: _deliveryTimeController,
    decoration: const InputDecoration(labelText: 'Delivery Time (minutes)'),
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter delivery time';
    }
    if (int.tryParse(value) == null) {
    return 'Please enter a valid number';
    }
    return null;
    },
    )
        : null,
    ),

    const SizedBox(height: defaultPadding * 1.5),

    // Edit/Save Button
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: () {
    if (_isEditing) {
    _updateVendorProfile();
    } else {
    setState(() {
    _isEditing = true;
    });
    }
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: _isEditing ? const Color(0xFF3498DB) : const Color(0xFF2d6a4f),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(
    _isEditing ? 'Save Changes' : 'Edit Profile',
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    ),
    ),

    const SizedBox(height: defaultPadding / 2),

    if (_isEditing)
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: _discardChanges,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: const Text(
    'Discard Changes',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    ),
    ),
    const SizedBox(height: defaultPadding / 2),

    // Logout Button
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: () => _logout(context),
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE74C3C),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: const Text(
    'Log Out',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    ),
    ),

    const SizedBox(height: defaultPadding),
    ],
    ),
    ),

    if (_updateErrorMessage != null)
    Positioned(
    bottom: 20,
    left: 20,
    right: 20,
    child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.redAccent,
    borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
    children: [
    const Icon(Icons.error, color: Colors.white),
    const SizedBox(width: 8),
    Expanded(
    child: Text(
    _updateErrorMessage!,
    style: const TextStyle(color: Colors.white),
    ),
    ),
    IconButton(
    icon: const Icon(Icons.close, color: Colors.white),
    onPressed: () {
    setState(() {
    _updateErrorMessage = null;
    });
    },
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ),
    );
    }
}

class ModernProfileTaskCard extends StatelessWidget {
  const ModernProfileTaskCard({
    super.key,
    required this.title,
    this.subTitle,
    required this.svgSrc,
    this.press,
    required this.color,
    this.child,
  });

  final String title;
  final String? subTitle;
  final String svgSrc;
  final VoidCallback? press;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: press,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  svgSrc,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (child == null && subTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subTitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    if (child != null) child!,
                  ],
                ),
              ),
              if (child == null)
                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}