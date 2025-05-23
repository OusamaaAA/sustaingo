import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../contactus/contactus.dart';
import '../../../screens/aboutus/aboutus.dart';
import '../../../screens/faq/faqbot.dart';
import '../../../constants.dart';
import '../auth/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

const String PROFILE_ENDPOINT = '/api/profile';
const String UPDATE_PROFILE_ENDPOINT = '/api/profile/update';

class _ProfileScreenState extends State<ProfileScreen> {
  String? fullName;
  String? email;
  String? phoneNumber;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _updateErrorMessage;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _updateErrorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
        return;
      }

      final response = await http.get(
        Uri.parse('https://sustaingobackend.onrender.com/api/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          fullName = data['full_name'] ?? '';
          email = data['email'] ?? '';
          phoneNumber = data['phone_number'] ?? '';
          _fullNameController.text = fullName ?? '';
          _emailController.text = email ?? '';
          _phoneController.text = phoneNumber ?? '';
        });
      } else {
        _handleErrorResponse(response);
      }
    } on http.ClientException catch (e) {
      _showNetworkError('Connection error: ${e.message}');
    } catch (e) {
      _showNetworkError('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserProfile() async {
    if (!_formKey.currentState!.validate() || !mounted) return;

    setState(() {
      _isUpdating = true;
      _updateErrorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
        return;
      }

      final updateUrl = Uri.parse('https://sustaingobackend.onrender.com/api/profile/update/');
      final requestBody = {
        'first_name': _fullNameController.text.split(' ').first,
        'last_name': _fullNameController.text.split(' ').length > 1
            ? _fullNameController.text.split(' ').last
            : '',
        'phone_number': _phoneController.text,
        // Removed email from the request body
      };

      final response = await http.patch(
        updateUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _updateErrorMessage = null;
        });
        await _loadUserProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      setState(() {
        _updateErrorMessage = 'Failed to update profile: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

void _handleErrorResponse(http.Response response) {
  if (!mounted) return;

  try {
    final errorData = json.decode(response.body);
    final errorMessage = errorData['detail'] ??
        errorData['message'] ??
        'Failed with status ${response.statusCode}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Unexpected error occurred.'),
    ));
  }
}


  
  void _showNetworkError(String message) {
    if (mounted) {
      setState(() => _updateErrorMessage = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          "Account Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2d6a4f)),
              accountName: const Text(
                'SustainGo',
                style: TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text(
                'Save Food, Save Money',
                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white70,
                child: Icon(Icons.restaurant_outlined,
                    size: 40, color: Color(0xFF2d6a4f)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.question_answer_outlined),
              title: const Text('FAQ Bot'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const FAQBotScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Contact Us'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ContactUsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
            ),
            const Divider(color: Colors.grey),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: Stack(
          children: [
            Body(
  isEditing: _isEditing,
  fullName: fullName,
  email: email,
  phoneNumber: phoneNumber,
  fullNameController: _fullNameController,
  emailController: _emailController,
  phoneController: _phoneController,
  onLogout: () => _logout(context),
  onUpdate: () => _updateUserProfile(), // Wrap with () =>
  onEditPressed: () {
    setState(() {
      _isEditing = !_isEditing;
      _updateErrorMessage = null;
    });
  },
  isUpdating: _isUpdating,
),

            if (_updateErrorMessage != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
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
                          setState(() => _updateErrorMessage = null);
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

class Body extends StatelessWidget {
  const Body({
    Key? key,
    this.onLogout,
    this.fullName,
    this.email,
    this.phoneNumber,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.onUpdate,
    this.isEditing = false,
    this.onEditPressed,
    this.isUpdating = false,
  }) : super(key: key);

  final VoidCallback? onLogout;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VoidCallback onUpdate;
  final bool isEditing;
  final VoidCallback? onEditPressed;
  final bool isUpdating;

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
                    isEditing ? 'Edit Profile' : fullName ?? 'Loading...',
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
              title: "Full Name",
              subTitle: isEditing ? null : fullName ?? 'No name provided.',
              color: const Color(0xFF60A917),
              onTap: () {},
              child: isEditing
                  ? TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              )
                  : null,
            ),
            ModernProfileTaskCard(
              svgSrc: "assets/icons/phone.svg",
              title: "Phone Number",
              subTitle: isEditing ? null : phoneNumber ?? 'No phone number provided.',
              color: const Color(0xFFE67E22),
              onTap: () {},
              child: isEditing
                  ? TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              )
                  : null,
            ),
            // Always show email as read-only (not editable)
            ModernProfileTaskCard(
              svgSrc: "assets/icons/mail.svg",
              title: "Email Address",
              subTitle: email ?? '',
              color: const Color(0xFF3498DB),
              onTap: () {},
            ),
            const SizedBox(height: defaultPadding * 1.5),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating ? null : () {
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: isUpdating
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Text(
                  isEditing ? 'Save Changes' : 'Edit Profile',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Log Out',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
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
    Key? key,
    required this.title,
    this.subTitle,
    this.svgSrc,
    required this.onTap,
    this.color,
    this.child,
  }) : super(key: key);

  final String title;
  final String? subTitle;
  final String? svgSrc;
  final VoidCallback onTap;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color?.withOpacity(0.08) ?? Colors.grey.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              if (svgSrc != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color?.withOpacity(0.8) ??
                        titleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    svgSrc!,
                    height: 22,
                    width: 22,
                    colorFilter: ColorFilter.mode(
                      color ?? titleColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              if (svgSrc != null)
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
                    if (child == null &&
                        subTitle != null &&
                        subTitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text(
                          subTitle!,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ),
                    if (child != null) child!,
                  ],
                ),
              ),
              if (child == null)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  
}