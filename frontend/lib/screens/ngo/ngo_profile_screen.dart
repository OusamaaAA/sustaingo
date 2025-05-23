import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../../screens/auth/sign_in_screen.dart';

class NGOProfileScreen extends StatefulWidget {
  const NGOProfileScreen({super.key});

  @override
  State<NGOProfileScreen> createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen> {
  String name = '';
  String? description;
  String? phone;
  String? email;
  String? location;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  String? _updateErrorMessage;

  @override
  void initState() {
    super.initState();
    fetchNGOProfile();
  }

  Future<void> fetchNGOProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('https://sustaingobackend.onrender.com/api/get_ngo_profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        name = data['organization_name'] ?? '';
        phone = data['phone_number']; // ✅  Get phone_number
        location = data['region'];
        description = data['description'];
        email = data['email'];

        _nameController.text = name;
        _descriptionController.text = description ?? '';
        _phoneController.text = phone ?? '';  // ✅ Set phoneController
        _emailController.text = email ?? '';
        _locationController.text = location ?? '';
      });
    } else {
      print('Failed to fetch NGO profile: ${response.statusCode}');
      print('Backend response: ${response.body}');
    }
  }

  Future<void> updateNGOProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse('https://sustaingobackend.onrender.com/api/update_ngo_profile/');
    final request = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['organization_name'] = _nameController.text
      ..fields['phone_number'] = _phoneController.text  // ✅ Send phone_number
      ..fields['region'] = _locationController.text
      ..fields['email'] = _emailController.text
      ..fields['description'] = _descriptionController.text;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      setState(() {
        name = _nameController.text;
        phone = _phoneController.text;  // ✅ Update phone
        location = _locationController.text;
        description = _descriptionController.text;
        email = _emailController.text;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      print('Update failed: ${response.statusCode}');
      print(response.body);
      setState(() {
        _updateErrorMessage = 'Failed to update profile. ${json.decode(response.body)['detail'] ?? ''}';
      });
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Use the correct key

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGO Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Body(
              isEditing: _isEditing,
              name: name,
              description: description,
              phone: phone,
              email: email,
              location: location,
              nameController: _nameController,
              descriptionController: _descriptionController,
              phoneController: _phoneController,
              emailController: _emailController,
              locationController: _locationController,
              onLogout: () => _logout(context),
              onUpdate: updateNGOProfile,
              onEditPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  _updateErrorMessage = null;
                });
              },
            ),
            if (_updateErrorMessage != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _updateErrorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
    this.onLogout,
    this.name,
    this.description,
    this.phone,
    this.email,
    this.location,
    required this.nameController,
    required this.descriptionController,
    required this.phoneController,
    required this.emailController,
    required this.locationController,
    required this.onUpdate,
    this.isEditing = false,
    this.onEditPressed,
  });

  final VoidCallback? onLogout;
  final String? name;
  final String? description;
  final String? phone;
  final String? email;
  final String? location;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController locationController;
  final VoidCallback onUpdate;
  final bool isEditing;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: defaultPadding * 1.5),
            Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    isEditing ? 'Edit Profile' : name ?? 'Loading...',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            ModernProfileTaskCard(
              svgSrc: "assets/icons/profile.svg",
              title: "Description",
              subTitle: isEditing ? null : description ?? 'No description provided.',
              color: const Color(0xFF60A917),
              press: () {},
              child: isEditing
                  ? TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              )
                  : null,
            ),
            ModernProfileTaskCard(
              svgSrc: "assets/icons/phone.svg",
              title: "Phone Number",
              subTitle: isEditing ? null : phone ?? 'No phone number provided.',
              color: const Color(0xFFE67E22),
              press: () {},
              child: isEditing
                  ? TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9), // Limit to 9 digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length < 7 || value.length > 9) {
                    return 'Phone number must be between 7 and 9 digits';
                  }
                  return null;
                },
              )
                  : null,
            ),
            ModernProfileTaskCard(
              svgSrc: "assets/icons/mail.svg",
              title: "Email Address",
              subTitle: isEditing ? null : email ?? '',
              color: const Color(0xFF3498DB),
              press: () {},
              child: isEditing
                  ? TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              )
                  : null,
            ),
            ModernProfileTaskCard(
              svgSrc: "assets/icons/marker.svg",
              title: "Location",
              subTitle: isEditing ? null : location ?? 'No location provided.',
              color: const Color(0xFF9B59B6),
              press: () {},
              child: isEditing
                  ? TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Region'),
              )
                  : null,
            ),
            const SizedBox(height: defaultPadding * 1.5),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    onUpdate();
                  } else {
                    onEditPressed?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isEditing ? const Color(0xFF3498DB) : const Color(0xFF2d6a4f),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Edit All Information',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: defaultPadding),
          ],
        ),
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
                  color: color?.withOpacity(0.8) ?? titleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  svgSrc!,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(color ?? titleColor, BlendMode.srcIn),
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
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ),
                    if (child != null) child!,
                  ],
                ),
              ),
              if (child == null)
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}