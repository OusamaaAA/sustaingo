import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../findRestaurants/find_restaurants_screen.dart';
import '../../vendor/vendor_home_screen.dart';
import '../../ngo/ngo_home_screen.dart';
import '../../../constants.dart';
import '../forgot_password_screen.dart';
import '../../../entry_point.dart';
import '../../../services/location_manager.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://sustaingobackend.onrender.com/api/login/');
    final body = {
      'username': _emailController.text.trim(),
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (!responseData.containsKey('access') ||
            !responseData.containsKey('refresh')) {
          throw Exception("Login response missing tokens");
        }

        final accessToken = responseData['access'];
        final refreshToken = responseData['refresh'];
        final role =
            responseData['role'] ??
            'user'; // fallback to 'user' if not provided

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('role', role);

        print("Access Token: $accessToken");
        print("Refresh Token: $refreshToken");
        print("Role: $role");

        // Navigate to appropriate screen
        Widget nextScreen;
        if (role == 'vendor') {
          nextScreen = const VendorHomeScreen();
        } else if (role == 'ngo') {
          nextScreen = const NGOHomeScreen();
        } else {
          nextScreen = const FindRestaurantsScreen();
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
          (_) => false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['detail'] ??
            'Login failed. Please check your credentials.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print("Login error: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: emailValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Email Address"),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            validator: passwordValidator.call,
            decoration: InputDecoration(
              hintText: "Password",
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureText = !_obscureText),
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: bodyTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                ),
            child: Text(
              "Forget Password?",
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
            child:
                _isLoading
                    ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                    : const Text("Sign in"),
          ),
        ],
      ),
    );
  }
}
