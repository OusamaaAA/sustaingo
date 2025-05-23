import 'package:flutter/material.dart';
import '../../../entry_point.dart'; // Adjust this import path as necessary
import '../../../constants.dart';
import '../../findRestaurants/find_restaurants_screen.dart'; // Adjust this import path as necessary

class OtpForm extends StatefulWidget {
  const OtpForm({super.key});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _otpFocusNodes[0].requestFocus(); // Focus on the first input when the form loads
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

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return ''; // Return empty string for now, to avoid red boxes.
    }
    if (value.length != 1) {
      return '';
    }
    return null;
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  String get _otpCode {
    String code = '';
    for (var controller in _otpControllers) {
      code += controller.text;
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the OTP inputs
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add horizontal padding
                child: SizedBox(
                  width: 48, // Keep a fixed size
                  height: 48,
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    onChanged: (value) => _onOtpChanged(value, index),
                    validator: _validateOtp,
                    maxLength: 1,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20), // Increase font size for better visibility
                    decoration: const InputDecoration( // Simplify the decoration
                      counterText: '', // Remove the character counter
                      border: OutlineInputBorder(), // Use a clear border
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor), // Highlight when focused
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: defaultPadding * 2),
          // Continue Button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Combine the OTP digits and proceed
                String otpCode = _otpCode;
                print('Entered OTP: $otpCode'); // Use for debugging
                // Navigate to the next screen (replace with your actual navigation logic)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindRestaurantsScreen(), //  Use pushReplacement
                  ),
                );
              }
            },
            child: const Text("Continue"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), // Adjust padding
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

