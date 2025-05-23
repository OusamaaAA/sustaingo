import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'components/sign_up_form.dart'; // Custom reusable sign-up form widget
import '../phoneLogin/otp_screen.dart'; // OTP verification screen
import '../../components/buttons/socal_button.dart'; // Social login button
import '../../components/welcome_text.dart'; // Reusable title/subtitle widget
import '../../constants.dart'; // App-wide constants like padding and colors
import 'sign_in_screen.dart'; // To navigate to sign-in screen

// Main Sign Up Screen as a StatefulWidget to handle form logic and loading state
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form key to validate and save form
  final _formKey = GlobalKey<FormState>();

  // Controllers for user input fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Loading indicator flag
  bool _isLoading = false;

  // Validator for phone number field
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your phone number";
    }
    if (value.length < 7) {
      return "Phone number must be at least 7 digits";
    }
    return null;
  }

  // Sign-up process with OTP step
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      // Prepare user registration data
      final registrationData = {
        "full_name": _fullNameController.text.trim(),
        "email": email,
        "password": _passwordController.text,
        "confirm_password": _confirmPasswordController.text,
        "phone": _phoneController.text.trim(),
      };

      // Show loading spinner
      setState(() => _isLoading = true);

      // Send request to backend for OTP
      final otpRequest = await http.post(
        Uri.parse('https://sustainfinal-vij7.onrender.com/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      // Stop loading spinner
      setState(() => _isLoading = false);

      // Navigate to OTP screen if successful
      if (otpRequest.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: email,
              registrationData: registrationData,
            ),
          ),
        );
      } else {
        // Show error message
        final error = jsonDecode(otpRequest.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['detail'] ?? 'OTP request failed')),
        );
      }
    }
  }

  // Placeholder functions for social login
  void _signInWithFacebook() {}
  void _signInWithGoogle() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom styled AppBar with icon and title
      appBar: AppBar(
        leading: const SizedBox(), // Removes back button
        title: Row(
          children: const [
            Icon(Icons.person_add_alt_1, color: Colors.white),
            SizedBox(width: 8.0),
            Text(
              "Sign Up",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // Main screen body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message at the top
              const WelcomeText(
                title: "Create Account",
                text: "Enter your Full Name, Email, Password, Confirm Password and Phone Number for sign up.",
              ),

              // Sign-up form (defined in a separate widget)
              SignUpForm(
                formKey: _formKey,
                fullNameController: _fullNameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                phoneController: _phoneController,
                phoneNumberValidator: _validatePhoneNumber,
              ),

              const SizedBox(height: defaultPadding),

              // Sign Up button (shows loading spinner if _isLoading is true)
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up"),
              ),

              const SizedBox(height: defaultPadding),

              // Navigation to Sign In screen
              Center(
                child: Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
                    text: "Already have an account? ",
                    children: <TextSpan>[
                      TextSpan(
                        text: "Sign In",
                        style: const TextStyle(color: primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignInScreen()),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: defaultPadding),

              // Terms and privacy notice
              Center(
                child: Text(
                  "By signing up, you agree to our Terms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: defaultPadding),

              // Separator ("OR")
              kOrText,

              const SizedBox(height: defaultPadding),

              // Facebook social login button
              SocalButton(
                press: _signInWithFacebook,
                text: "Connect with Facebook",
                color: const Color(0xFF395998),
                icon: SvgPicture.asset(
                  'assets/icons/facebook.svg',
                  colorFilter: const ColorFilter.mode(Color(0xFF395998), BlendMode.srcIn),
                ),
              ),

              const SizedBox(height: defaultPadding),

              // Google social login button
              SocalButton(
                press: _signInWithGoogle,
                text: "Connect with Google",
                color: const Color(0xFF4285F4),
                icon: SvgPicture.asset('assets/icons/google.svg'),
              ),

              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
