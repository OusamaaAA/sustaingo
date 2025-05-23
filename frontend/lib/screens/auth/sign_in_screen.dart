// sign_in_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/buttons/socal_button.dart'; // Custom social login button widget
import '../../components/welcome_text.dart'; // Reusable welcome text widget
import '../../constants.dart'; // Contains constants like defaultPadding and primaryColor
import 'sign_up_screen.dart'; // Sign-up screen to navigate to
import 'components/sign_in_form.dart'; // Form widget for email/password login

// Main Sign In Screen Widget
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  // Function to handle Facebook sign-in
  void _signInWithFacebook(BuildContext context) {
    print("Signing in with Facebook");
    // TODO: Implement Facebook sign-in logic
  }

  // Function to handle Google sign-in
  void _signInWithGoogle(BuildContext context) {
    print("Signing in with Google");
    // TODO: Implement Google sign-in logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar with icon and title
      appBar: AppBar(
        leading: const SizedBox(), // No back button
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white), // Leading icon
            const SizedBox(width: 8.0),
            const Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2d6a4f), // Green theme color
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // Scrollable screen body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              const WelcomeText(
                title: "Welcome to SustainGo",
                text: "Kindly use your Phone Number or Email Address to Sign in.",
              ),

              // Email/Password Sign In Form
              const SignInForm(),

              const SizedBox(height: defaultPadding),

              // Separator Text ("OR")
              kOrText,

              const SizedBox(height: defaultPadding * 1.5),

              // Navigation to Sign Up screen
              Center(
                child: Text.rich(
                  TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontWeight: FontWeight.w600),
                    text: "Don’t have an account? ",
                    children: <TextSpan>[
                      TextSpan(
                        text: "Create new account.",
                        style: const TextStyle(color: primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: defaultPadding),

              // Facebook login button
              SocalButton(
                press: () => _signInWithFacebook(context),
                text: "Connect with Facebook",
                color: const Color(0xFF395998),
                icon: SvgPicture.asset(
                  'assets/icons/facebook.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF395998),
                    BlendMode.srcIn,
                  ),
                ),
              ),

              const SizedBox(height: defaultPadding),

              // Google login button
              SocalButton(
                press: () => _signInWithGoogle(context),
                text: "Connect with Google",
                color: const Color(0xFF4285F4),
                icon: SvgPicture.asset(
                  'assets/icons/google.svg',
                ),
              ),

              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
