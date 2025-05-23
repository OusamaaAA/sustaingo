import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../screens/auth/sign_in_screen.dart';
import 'deliv_order_card.dart';
import 'deliv_order_details.dart';
import 'deliveries.dart';

class DelivProfileScreen extends StatefulWidget {
  const DelivProfileScreen({super.key});

  @override
  State<DelivProfileScreen> createState() => _DelivProfileScreenState();
}

class _DelivProfileScreenState extends State<DelivProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _plateController = TextEditingController();
  String? _selectedVehicle;
  String? _updateErrorMessage;
  int _selectedIndex = 2; // Initialize to the Profile index

  final List<String> _vehicleTypes = [
    'Motorcycle',
    'Bicycle',
    'Car',
    'Scooter',
    'Electric Bike',
    'Walking'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock response
      final mockResponse = {
        'name': 'Ali Hassan',
        'phone': '76123456',
        'email': 'ali.hassan@example.com',
        'vehicle_type': 'Motorcycle',
        'plate_number': 'BE 12345'
      };

      setState(() {
        _nameController.text = mockResponse['name'] ?? '';
        _phoneController.text = mockResponse['phone'] ?? '';
        _emailController.text = mockResponse['email'] ?? '';
        _selectedVehicle = mockResponse['vehicle_type'];
        _plateController.text = mockResponse['plate_number'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _updateErrorMessage = 'Failed to load profile data';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _updateErrorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      try {
        // here were simulating the api use
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        setState(() {
          _updateErrorMessage = 'Failed to update profile. Please try again.';
        });
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    final phoneRegex = RegExp(r'^[0-9]{7,8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid Lebanese phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email address';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Navigate to Home screen (replace with your actual Home screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Placeholder()), // Replace Placeholder with your Home screen widget
      );
    } else if (index == 1) {
      // Navigate to Deliveries screen, passing the completedDeliveries data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DeliveriesScreen(completedDeliveries: [])), // Pass an empty list or fetch the data here
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Delivery Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                          radius: 50,
                          backgroundColor: const Color(0xFF2d6a4f),
                          child: SvgPicture.asset(
                            'assets/icons/vehicle.svg',
                            colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          _isEditing ? 'Edit Profile' : _nameController.text,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: defaultPadding),
                      ],
                    ),
                  ),
                  ModernProfileTaskCard(
                    svgSrc: "assets/icons/phone.svg",
                    title: "Phone Number",
                    subTitle: _isEditing ? null : _phoneController.text,
                    color: const Color(0xFFE67E22),
                    press: () {},
                    child: _isEditing
                        ? TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'eg: 76 123 456'),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    )
                        : null,
                  ),
                  ModernProfileTaskCard(
                    svgSrc: "assets/icons/mail.svg",
                    title: "Email Address",
                    subTitle: _isEditing ? null : _emailController.text,
                    color: const Color(0xFF3498DB),
                    press: () {},
                    child: _isEditing
                        ? TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email Address'),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    )
                        : null,
                  ),
                  ModernProfileTaskCard(
                    svgSrc: "assets/icons/directions_bike.svg",
                    title: "Vehicle Type",
                    subTitle: _isEditing ? null : _selectedVehicle,
                    color: const Color(0xFF9B59B6),
                    press: () {},
                    child: _isEditing
                        ? DropdownButtonFormField<String>(
                      value: _selectedVehicle,
                      decoration: const InputDecoration(
                          labelText: 'Vehicle Type'),
                      items: _vehicleTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedVehicle = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select vehicle type';
                        }
                        return null;
                      },
                    )
                        : null,
                  ),
                  ModernProfileTaskCard(
                    svgSrc: "assets/icons/confirmation_number.svg",
                    title: "Plate Number",
                    subTitle: _isEditing ? null : _plateController.text,
                    color: const Color(0xFF60A917),
                    press: () {},
                    child: _isEditing
                        ? TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                          labelText: 'Plate Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter plate number';
                        }
                        return null;
                      },
                    )
                        : null,
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditing) {
                          _updateProfile();
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing
                            ? const Color(0xFF3498DB)
                            : const Color(0xFF2d6a4f),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Edit Profile',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
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
                  child: Text(
                    _updateErrorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/vehicle.svg',
              width: 24,
              height: 24,
            ),
            label: 'Deliveries',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected tab
        selectedItemColor: const Color(0xFF2d6a4f),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // If Profile tab is selected, no need to navigate again as we are already here
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Placeholder()), // Replace Placeholder with your actual Home screen widget
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DeliveriesScreen(completedDeliveries: [])),
            );
          } else {
            setState(() {
              _selectedIndex = index; // Update selected index for the current screen
            });
          }
        },
        backgroundColor: Colors.white, // Bottom bar background color
        elevation: 10, // Bottom bar elevation for shadow effect
      ),
    );
  }
}

class ModernProfileTaskCard extends StatelessWidget {
  const ModernProfileTaskCard({
    super.key,
    this.title,
    this.subTitle,
    this.svgSrc,
    this.press,
    this.color,
    this.child,
  });

  final String? title, subTitle, svgSrc;
  final VoidCallback? press;
  final Color? color;
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
            color: color?.withOpacity(0.08) ?? Colors.grey.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color?.withOpacity(0.8) ?? Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  svgSrc!,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(
                      color ?? Colors.grey,
                      BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (child == null && subTitle != null && subTitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text(
                          subTitle!,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600),
                        ),
                      ),
                    if (child != null) child!,
                  ],
                ),
              ),
              if (child == null)
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18),
            ],
          ),
        ),
      ),
    );
  }
}