import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../findRestaurants/find_restaurants_screen.dart';
import '../ngo/ngo_home_screen.dart';
import '../vendor/vendor_home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic> registrationData;

  const OtpScreen({super.key, required this.email, required this.registrationData});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpFocusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtpAndRegister() async {
    if (_otpCode.length != 6) return;

    setState(() => _isLoading = true);

    final verifyResponse = await http.post(
      Uri.parse('https://sustainfinal-vij7.onrender.com/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'otp': _otpCode}),
    );

    if (verifyResponse.statusCode == 200) {
      final registerResponse = await http.post(
        Uri.parse('https://sustaingobackend.onrender.com/api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.registrationData),
      );

      if (registerResponse.statusCode == 201) {
        // ✅ Now login to get the token
        final loginResponse = await http.post(
          Uri.parse('https://sustaingobackend.onrender.com/api/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': widget.registrationData['email'],
            'password': widget.registrationData['password'],
          }),
        );

        if (loginResponse.statusCode == 200) {
          final data = jsonDecode(loginResponse.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['access']);
          await prefs.setString('refresh_token', data['refresh']);
          await prefs.setString('role', data['role']);

          Widget nextScreen;
          if (data['role'] == 'vendor') {
            nextScreen = const VendorHomeScreen();
          } else if (data['role'] == 'ngo') {
            nextScreen = const NGOHomeScreen();
          } else {
            nextScreen = const FindRestaurantsScreen();
          }

          setState(() => _isLoading = false);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => nextScreen),
            (_) => false,
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed after registration")),
          );
        }
      } else {
        setState(() => _isLoading = false);
        final error = jsonDecode(registerResponse.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['detail'] ?? 'Registration failed')),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text("Enter 6-digit code", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("We've sent a verification code to your email", textAlign: TextAlign.center),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 60,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _otpFocusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _otpFocusNodes[index - 1].requestFocus();
                        }
                      },
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.grey[100],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2d6a4f), width: 2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtpAndRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2d6a4f),
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify & Continue", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}