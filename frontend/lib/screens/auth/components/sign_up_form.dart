import 'package:flutter/material.dart';
import '../../../constants.dart';

class SignUpForm extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final TextEditingController? fullNameController;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final TextEditingController? phoneController;
  final String? Function(String?)? phoneNumberValidator;

  const SignUpForm({
    super.key,
    this.formKey,
    this.fullNameController,
    this.emailController,
    this.passwordController,
    this.confirmPasswordController,
    this.phoneController,
    this.phoneNumberValidator,
  });

  Map<String, dynamic> get registrationData => {
    'full_name': fullNameController?.text.trim(),
    'email': emailController?.text.trim(),
    'password': passwordController?.text,
    'confirm_password': confirmPasswordController?.text,
    'phone': phoneController?.text.trim(),
  };

  String get email => emailController?.text.trim() ?? '';

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _obscureText = true;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must include a special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value != widget.passwordController?.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your full name';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: widget.fullNameController,
            validator: _validateFullName,
            decoration: const InputDecoration(hintText: "Full Name"),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Email Address"),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.phoneController,
            validator: widget.phoneNumberValidator,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: "Phone Number"),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscureText,
            validator: _validatePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Password",
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: bodyTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: widget.confirmPasswordController,
            obscureText: _obscureText,
            validator: _validateConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "Confirm Password",
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: bodyTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding * 1.5),
        ],
      ),
    );
  }
}