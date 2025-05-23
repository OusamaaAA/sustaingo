import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart'; // For date/time formatting

class AddMysteryBagScreen extends StatefulWidget {
  const AddMysteryBagScreen({super.key});

  @override
  State<AddMysteryBagScreen> createState() => _AddMysteryBagScreenState();
}

class _AddMysteryBagScreenState extends State<AddMysteryBagScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hiddenContentsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _pickupStartController = TextEditingController();
  final TextEditingController _pickupEndController = TextEditingController();

  bool _isDonation = false;
  bool _isSubmitting = false;

  // Function to show a styled SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? Colors.white : Colors.white),
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF2d6a4f), // Consistent green
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _submitBag() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final success = await ApiService().createMysteryBag(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          hiddenContents: _hiddenContentsController.text.trim(),
          price: double.tryParse(_priceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
          quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
          pickupStart: _pickupStartController.text.trim(),
          pickupEnd: _pickupEndController.text.trim(),
          isDonation: _isDonation,
        );

        if (success) {
          _showSnackBar('Mystery Bag created successfully!');
          Navigator.pop(context, true);
        } else {
          _showSnackBar('Failed to create Mystery Bag', isError: true);
        }
      } catch (error) {
        _showSnackBar('An error occurred: $error', isError: true);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hiddenContentsController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _pickupStartController.dispose();
    _pickupEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Mystery Bag', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container( // Added a Container here
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration( // Added a BoxDecoration for the gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFf0f4f3), // Light background
              Color(0xFFe0e0e0),
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_titleController, 'Title', requiredField: true),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'General Description', requiredField: true),
              const SizedBox(height: 16),
              _buildTextField(_hiddenContentsController, 'Hidden Contents', requiredField: true),
              const SizedBox(height: 16),
              _buildTextField(
                _priceController,
                'Price',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                requiredField: !_isDonation,
                validator: _validatePrice,
                inputFormatter: _priceInputFormatter,
              ),
              const SizedBox(height: 16),
              _buildTextField(_quantityController, 'Quantity Available', keyboardType: TextInputType.number, requiredField: true),
              const SizedBox(height: 16),
              _buildTextField(_pickupStartController, 'Pickup Start Time (HH:MM)', requiredField: true, validator: _validateTime, inputFormatter: _timeInputFormatter),
              const SizedBox(height: 16),
              _buildTextField(_pickupEndController, 'Pickup End Time (HH:MM)', requiredField: true, validator: _validateTime, inputFormatter: _timeInputFormatter),
              const SizedBox(height: 16),
              _buildDonationSwitch(), // Separate method for the switch
              const SizedBox(height: 24),
              _buildSubmitButton(), // Separate method for submit button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8), // Add padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white, // Background color for the switch container
      ),
      child: SwitchListTile(
        title: const Text(
          'Is it a Donation?',
          style: TextStyle(
            fontWeight: FontWeight.w500, // Medium font weight
            color: Colors.black87,
          ),
        ),
        value: _isDonation,
        activeColor: const Color(0xFF2d6a4f),
        onChanged: (value) {
          setState(() {
            _isDonation = value;
          });
        },
        contentPadding: EdgeInsets.zero, // Remove default padding
      ),
    );
  }

  Widget _buildSubmitButton() {
    return _isSubmitting
        ? const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2d6a4f)),
    )
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2d6a4f),
        padding: const EdgeInsets.symmetric(vertical: 18), // Increased vertical padding
        minimumSize: const Size(double.infinity, 50), // Increased height
        shape: RoundedRectangleBorder( // Rounded corners
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3, // Add a slight shadow
      ),
      onPressed: _submitBag,
      child: const Text(
        'Create Bag',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), // Medium font weight for button text
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool requiredField = false,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        TextInputFormatter? inputFormatter}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [ // Add a slight shadow to the text field container
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none, // Remove the default border
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Add padding
          floatingLabelBehavior: FloatingLabelBehavior.always, // Ensure label is always floating
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500, // Medium font weight for label
            color: Colors.black87,
          ),
        ),
        validator: validator ?? (value) {
          if (requiredField && (value == null || value.isEmpty)) {
            return 'Please enter $labelText';
          }
          return null;
        },
        inputFormatters: inputFormatter != null ? [inputFormatter] : null,
        style: const TextStyle(color: Colors.black87), // Set text color
      ),
    );
  }

  String? _validatePrice(String? value) {
    final regex = RegExp(r'^[0-9]+(\.[0-9]{1,2})?$');
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid price (e.g., 10 or 10.99)';
    }
    return null;
  }

  String? _validateTime(String? value) {
    final regex = RegExp(r'^(2[0-3]|[01]?[0-9]):([0-5]?[0-9])$');
    if (value == null || value.isEmpty) {
      return 'Enter time (HH:MM)';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid time (HH:MM)';
    }
    return null;
  }

  TextInputFormatter get _priceInputFormatter => FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]{0,2}'));


  TextInputFormatter get _timeInputFormatter => TextInputFormatter.withFunction((oldValue, newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length >= 3) {
      text = text.substring(0, 2) + ':' + text.substring(2, 4);
    }
    return newValue.copyWith(text: text);
  });
}

