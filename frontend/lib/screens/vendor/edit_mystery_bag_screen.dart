import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class EditMysteryBagScreen extends StatefulWidget {
  final Map<String, dynamic> bag;

  const EditMysteryBagScreen({super.key, required this.bag});

  @override
  State<EditMysteryBagScreen> createState() => _EditMysteryBagScreenState();
}

class _EditMysteryBagScreenState extends State<EditMysteryBagScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hiddenContentsController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _pickupStartController;
  late TextEditingController _pickupEndController;

  bool _isDonation = false;
  bool _isSubmitting = false;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? Colors.white : Colors.white),
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF2d6a4f),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bag['title']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.bag['description']?.toString() ?? '');
    _hiddenContentsController = TextEditingController(
        text: widget.bag['hidden_contents']?.toString() ?? ''
    );
    _priceController = TextEditingController(
        text: (widget.bag['price'] ?? 0.0).toString()
    );
    _quantityController = TextEditingController(
        text: (widget.bag['quantity_available'] ?? 1).toString()
    );

    // Format pickup times
    String pickupStart = widget.bag['pickup_start']?.toString() ?? "00:00";
    String pickupEnd = widget.bag['pickup_end']?.toString() ?? "00:00";
    pickupStart = pickupStart.length > 5 ? pickupStart.substring(0, 5) : pickupStart;
    pickupEnd = pickupEnd.length > 5 ? pickupEnd.substring(0, 5) : pickupEnd;

    _pickupStartController = TextEditingController(text: pickupStart);
    _pickupEndController = TextEditingController(text: pickupEnd);
    _isDonation = widget.bag['is_donation'] ?? false;

    debugPrint("Initializing EditMysteryBagScreen with: ${widget.bag}");
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final ApiService apiService = ApiService();
        final bool success;
        if (widget.bag['id'] == null) {
          // Creating new bag - using original create method
          success = await apiService.createMysteryBag(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            hiddenContents: _hiddenContentsController.text.trim(),
            price: double.tryParse(_priceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
            quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
            pickupStart: _pickupStartController.text.trim(),
            pickupEnd: _pickupEndController.text.trim(),
            isDonation: _isDonation,
          );
        } else {
          // Updating existing bag - using  update method
          success = await apiService.updateMysteryBag(
            bagId: widget.bag['id'],
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            hiddenContents: _hiddenContentsController.text.trim(),
            price: double.tryParse(_priceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
            quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
            pickupStart: _pickupStartController.text.trim(),
            pickupEnd: _pickupEndController.text.trim(),
            isDonation: _isDonation,
          );
        }

        if (success) {
          _showSnackBar('Mystery Bag ${widget.bag['id'] == null ? 'created' : 'updated'} successfully!');
          if (mounted) Navigator.pop(context, true);
        } else {
          _showSnackBar('Failed to ${widget.bag['id'] == null ? 'create' : 'update'} bag', isError: true);
        }
      } catch (error) {
        debugPrint("Error submitting form: $error");
        _showSnackBar('An error occurred: ${error.toString()}', isError: true);
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bag['id'] == null ? 'Create Mystery Bag' : 'Edit Mystery Bag',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFf0f4f3),
              Color(0xFFe0e0e0),
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_titleController, 'Title', requiredField: true),
                const SizedBox(height: 16),
                _buildTextField(_descriptionController, 'Description', requiredField: true),
                const SizedBox(height: 16),
                _buildTextField(
                  _hiddenContentsController,
                  'Hidden Contents',
                  requiredField: true,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _priceController,
                  'Price',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  requiredField: !_isDonation,
                  validator: _validatePrice,
                  inputFormatter: _priceInputFormatter,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _quantityController,
                  'Quantity Available',
                  keyboardType: TextInputType.number,
                  requiredField: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _pickupStartController,
                  'Pickup Start (HH:MM)',
                  requiredField: true,
                  validator: _validateTime,
                  inputFormatter: _timeInputFormatter,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _pickupEndController,
                  'Pickup End (HH:MM)',
                  requiredField: true,
                  validator: _validateTime,
                  inputFormatter: _timeInputFormatter,
                ),
                const SizedBox(height: 16),
                _buildDonationSwitch(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonationSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: SwitchListTile(
        title: const Text(
          'Is Donation?',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        value: _isDonation,
        activeColor: const Color(0xFF2d6a4f),
        onChanged: (value) => setState(() => _isDonation = value),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: _isSubmitting
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2d6a4f)),
        ),
      )
          : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2d6a4f),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        onPressed: _submitForm,
        child: Text(
          widget.bag['id'] == null ? 'Create Bag' : 'Update Bag',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText, {
        bool requiredField = false,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        TextInputFormatter? inputFormatter,
        int maxLines = 1,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
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
        maxLines: maxLines,
        minLines: 1,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  String? _validatePrice(String? value) {
    if (!_isDonation) {
      if (value == null || value.isEmpty) return 'Please enter a price';
      final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (parsed == null) return 'Invalid price format';
      if (parsed < 0) return 'Price cannot be negative';
    }
    return null;
  }

  String? _validateTime(String? value) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (value == null || value.isEmpty) return 'Please enter time';
    if (!regex.hasMatch(value)) return 'Use HH:MM format';
    return null;
  }

  final _priceInputFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

  final _timeInputFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 4) return oldValue;
    if (text.length > 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}:${text.substring(2)}',
        selection: TextSelection.collapsed(offset: newValue.text.length + 1),
      );
    }
    return newValue;
  });
}