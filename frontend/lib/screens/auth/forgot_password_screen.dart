import 'package:flutter/material.dart';
import 'reset_email_sent_screen.dart';

import '../../components/welcome_text.dart';
import '../../constants.dart';

// Main Forgot Password Screen (Stateless because it just wraps the form)
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and back button styling
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            color: Colors.white, // White title text
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2d6a4f), // Moss green background
        elevation: 4, // Adds slight shadow under the app bar
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Rounded bottom corners
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),

      // Body of the screen with scrollable content
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom welcome text explaining purpose
            WelcomeText(
              title: "Forgot password",
              text: "Enter your email address and we will \nsend you a reset instructions.",
            ),
            SizedBox(height: defaultPadding), // Spacing
            ForgotPassForm(), // Form widget for email input and reset button
          ],
        ),
      ),
    );
  }
}

// Form widget where user enters email to reset password
class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  State<ForgotPassForm> createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Assign key to form
      child: Column(
        children: [
          // Email input field
          TextFormField(
            validator: emailValidator.call, // Email validation logic from constants
            onSaved: (value) {}, // Placeholder for saving the value
            keyboardType: TextInputType.emailAddress, // Brings up email-optimized keyboard
            decoration: const InputDecoration(
              hintText: "Email Address", // Hint shown inside input field
            ),
          ),
          const SizedBox(height: defaultPadding), // Spacing below email input

          // Submit button to send reset link
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // If email input is valid
                _formKey.currentState!.save(); // Save form state
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResetEmailSentScreen(), // Navigate to confirmation screen
                  ),
                );
              }
            },
            child: const Text("Reset password"), // Button text
          ),
        ],
      ),
    );
  }
}
