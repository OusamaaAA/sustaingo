import 'package:flutter/material.dart';

import '../../constants.dart'; // Contains defaultPadding and other shared constants
import '../../components/welcome_text.dart'; // Reusable welcome message component

// Screen that confirms a reset email has been sent
class ResetEmailSentScreen extends StatelessWidget {
  const ResetEmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with default title
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),

      // Scrollable body with padding
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational message using WelcomeText component
            const WelcomeText(
              title: "Reset email sent",
              text: "We have sent a instructions email to \ntheflutterway@email.com.",
            ),

            const SizedBox(height: defaultPadding), // Spacer

            // Button to resend the reset email (onPressed currently empty)
            ElevatedButton(
              onPressed: () {}, // TODO: Add functionality to resend email
              child: const Text("Send again"), // Button label
            ),
          ],
        ),
      ),
    );
  }
}
