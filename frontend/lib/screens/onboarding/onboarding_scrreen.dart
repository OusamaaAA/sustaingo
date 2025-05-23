import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../components/dot_indicators.dart';
import '../auth/sign_in_screen.dart'; // Ensure this import is correct
import 'components/onboard_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  final List<Map<String, String>> _onboardingData = const [
    {
      "illustration": "assets/Illustrations/SustainGo_Logo.svg",
      "title": "Welcome",
      "text": "Order from the best local restaurants \nwith easy, on-demand delivery.",
    },
    // Add more onboarding data if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Expanded(
                flex: 14,
                child: PageView.builder(
                  itemCount: _onboardingData.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) => OnboardContent(
                    illustration: _onboardingData[index]["illustration"]!,
                    title: _onboardingData[index]["title"]!,
                    text: _onboardingData[index]["text"]!,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                      (index) => DotIndicator(isActive: index == currentPage),
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement( // Use pushReplacement to avoid going back to onboarding
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: Text("Get Started".toUpperCase()),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}