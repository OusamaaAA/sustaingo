import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';
import '../addToOrder/reservation_confirmation_screen.dart';

class AddToOrderScreen extends StatefulWidget {
  final int bagId;
  final String title;
  final String description;
  final double price;

  const AddToOrderScreen({
    super.key,
    required this.bagId,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  State<AddToOrderScreen> createState() => _AddToOrderScreenState();
}

enum PaymentMethod { cashOnDelivery, creditCard }

class _AddToOrderScreenState extends State<AddToOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  PaymentMethod? _paymentMethod = PaymentMethod.cashOnDelivery;
  String? _selectedCardType;
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  bool _isSubmitting = false;
  double _deliveryFee = 0.0;

  late MaskTextInputFormatter _expiryDateFormatter;
  late MaskTextInputFormatter _cvvFormatter;
  final MaskTextInputFormatter _cardNumberFormatter = MaskTextInputFormatter(
    mask: '####-####-####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _expiryDateFormatter = MaskTextInputFormatter(
      mask: 'MM/YY',
      filter: {"M": RegExp(r'[0-1]')},
      initialText: 'MM/YY',
    );
    _cvvFormatter = MaskTextInputFormatter(
      mask: '###',
      filter: {"#": RegExp(r'[0-9]')},
    );
    _calculateDeliveryFee();
  }

  void _calculateDeliveryFee() {
    setState(() {
      _deliveryFee = widget.price < 20 ? 1.49 : 0.0;
    });
  }

  double get _finalTotalPrice => widget.price + _deliveryFee;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        prefixIcon: prefixIcon,
      ),
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Method'),
        ListTile(
          title: const Text('Cash on Delivery', style: TextStyle(fontSize: 14)),
          leading: Radio<PaymentMethod>(
            value: PaymentMethod.cashOnDelivery,
            groupValue: _paymentMethod,
            onChanged: (PaymentMethod? value) {
              setState(() {
                _paymentMethod = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Credit Card', style: TextStyle(fontSize: 14)),
          leading: Radio<PaymentMethod>(
            value: PaymentMethod.creditCard,
            groupValue: _paymentMethod,
            onChanged: (PaymentMethod? value) {
              setState(() {
                _paymentMethod = value;
              });
            },
          ),
        ),
        if (_paymentMethod == PaymentMethod.creditCard)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Credit Card Details'),
                const SizedBox(height: 10),
                _buildCardTypeSelector(),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _cardHolderNameController,
                  labelText: 'Cardholder Name',
                  validator: (value) {
                    if (_paymentMethod == PaymentMethod.creditCard &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter the name on the card';
                    }
                    if (value != null &&
                        !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Cardholder name can only contain letters and spaces';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.person_outline),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _cardNumberController,
                  labelText: 'Card Number',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cardNumberFormatter],
                  validator: (value) {
                    if (_paymentMethod == PaymentMethod.creditCard &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter your card number';
                    }
                    final cleanedCardNumber = value?.replaceAll('-', '') ?? '';
                    if (cleanedCardNumber.length != 16) {
                      return 'Card number must be 16 digits';
                    }
                    if (_selectedCardType == null) {
                      return 'Please select a card type';
                    }
                    if (!isValidCreditCard(cleanedCardNumber)) {
                      return 'Please enter a valid card number';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.credit_card_outlined),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _expiryDateController,
                        labelText: 'Expiry (MM/YY)',
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: 'MM/YY',
                            filter: {
                              "M": RegExp(r'[0-9]'),
                              "Y": RegExp(r'[0-9]'),
                            },
                          ),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            // Only validate when we have at least 2 characters (month portion)
                            if (newValue.text.length >= 2) {
                              final month = int.tryParse(
                                newValue.text.substring(0, 2),
                              );
                              if (month == null || month < 1 || month > 12) {
                                return oldValue; // Reject invalid months
                              }
                            }
                            return newValue;
                          }),
                        ],
                        validator: (value) {
                          if (_paymentMethod == PaymentMethod.creditCard &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter the expiry date';
                          }
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                              return 'Please enter in MM/YY format';
                            }

                            final parts = value.split('/');
                            final month = int.tryParse(parts[0]);
                            final year = int.tryParse(parts[1]);

                            // Month validation (01-12)
                            if (month == null || month < 1 || month > 12) {
                              return 'Month must be between 01 and 12';
                            }

                            // Year validation
                            final now = DateTime.now();
                            final currentYear = now.year % 100;
                            final currentMonth = now.month;

                            if (year == null ||
                                year < currentYear ||
                                (year == currentYear && month < currentMonth)) {
                              return 'Card is expired';
                            }
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        controller: _cvvController,
                        labelText: 'CVV',
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cvvFormatter],
                        validator: (value) {
                          if (_paymentMethod == PaymentMethod.creditCard &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter the CVV';
                          }
                          if (value != null && value.isNotEmpty) {
                            if ((_selectedCardType == 'American Express' &&
                                    value.length != 4) ||
                                ([
                                      'Visa',
                                      'Mastercard',
                                      'Discover',
                                    ].contains(_selectedCardType) &&
                                    value.length != 3)) {
                              return 'Please enter a valid CVV';
                            }
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCardTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Type:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: <Widget>[
            _buildCardImageSelector('Visa'),
            _buildCardImageSelector('Mastercard'),
            _buildCardImageSelector('American Express'),
            _buildCardImageSelector('Discover'),
          ],
        ),
        if (_selectedCardType == null &&
            _paymentMethod == PaymentMethod.creditCard)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a card type',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCardImageSelector(String cardType) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardType = cardType;
          if (cardType == 'American Express') {
            _cvvFormatter = MaskTextInputFormatter(
              mask: '####',
              filter: {"#": RegExp(r'[0-9]')},
            );
          } else {
            _cvvFormatter = MaskTextInputFormatter(
              mask: '###',
              filter: {"#": RegExp(r'[0-9]')},
            );
          }
          _cvvController.clear();
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _selectedCardType == cardType
                        ? Colors.green
                        : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _getCardIcon(cardType),
          ),
          const SizedBox(width: 4),
          Text(cardType),
        ],
      ),
    );
  }

  Widget _getCardIcon(String cardType) {
    switch (cardType) {
      case 'Visa':
        return SvgPicture.asset('assets/images/visa.svg', height: 30);
      case 'Mastercard':
        return SvgPicture.asset('assets/images/mastercard.svg', height: 30);
      case 'American Express':
        return SvgPicture.asset('assets/images/amex.svg', height: 30);
      case 'Discover':
        return SvgPicture.asset('assets/images/discover.svg', height: 30);
      default:
        return const SizedBox(width: 30);
    }
  }

  bool isValidCreditCard(String cardNumber) {
    // Luhn algorithm implementation
    String cleanedCardNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedCardNumber.isEmpty) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = cleanedCardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanedCardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit ~/ 10) + (digit % 10);
        }
      }
      sum += digit;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Order Summary'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.title} x 1', style: const TextStyle(fontSize: 14)),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 14)),
                Text(
                  '\$${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery:', style: TextStyle(fontSize: 14)),
                Text(
                  widget.price < 20
                      ? '\$${_deliveryFee.toStringAsFixed(2)}'
                      : 'FREE',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_finalTotalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReservation() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSubmitting = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString('auth_token');

    print('➡️ Token being sent: $token');

    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first to make a reservation'),
          ),
        );
      }
      return;
    }

    Map<String, dynamic> requestBody = {
      'delivery_address': _addressController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'payment_method':
          _paymentMethod == PaymentMethod.creditCard ? 'credit_card' : 'cash_on_delivery',
      'notes': _notesController.text.trim(),
    };

    if (_paymentMethod == PaymentMethod.creditCard) {
      requestBody.addAll({
        'card_type': _selectedCardType ?? '',
        'card_number': _cardNumberController.text.replaceAll('-', ''),
        'expiry_date': _expiryDateController.text,
        'cvv': _cvvController.text,
        'card_holder_name': _cardHolderNameController.text.trim(),
      });
    }

    final url = Uri.parse(
      'https://sustaingobackend.onrender.com/api/bags/${widget.bagId}/reserve/',
    );

    print('Making request to: $url');
    print('Request body: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
  final responseData = jsonDecode(response.body);

  final List<String> items = List<String>.from(responseData['items'] ?? []);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => ReservationConfirmationScreen(
        bagContents: items,
      ),
    ),
  );
}
 else {
  try {
    final error = jsonDecode(response.body);
    final errorMessage = error['detail'] ?? error['message'] ?? 'Reservation failed';
    throw Exception(errorMessage);
  } catch (e) {
    throw Exception('Reservation failed');
  }
}

  } catch (e) {
    print('Error during reservation: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}


  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Confirmation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delivery Address: ${_addressController.text}'),
                Text('Phone Number: ${_phoneController.text}'),
                Text(
                  'Payment Method: ${_paymentMethod == PaymentMethod.creditCard ? 'Credit Card ($_selectedCardType)' : 'Cash on Delivery'}',
                ),
                if (_paymentMethod == PaymentMethod.creditCard) ...[
                  Text('Name on card: ${_cardHolderNameController.text}'),
                  Text(
                    'Card Number: ****-****-****-${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}',
                  ),
                  Text('Expiry Date: ${_expiryDateController.text}'),
                  Text('Security Code: ${_cvvController.text}'),
                ],
                Text(
                  'Delivery Fee: ${widget.price < 20 ? '\$${_deliveryFee.toStringAsFixed(2)}' : 'FREE'}',
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Total Amount: \$${_finalTotalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (_notesController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_notesController.text),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed:
                  _isSubmitting
                      ? null
                      : () {
                        Navigator.of(context).pop();
                        _submitReservation();
                      },
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                        'Confirm Reservation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reserve Mystery Bag",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Add this line
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.description),
                      const SizedBox(height: 12),
                      Text(
                        'Price: \$${widget.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildSectionTitle('Delivery Details'),
              _buildTextField(
                controller: _addressController,
                labelText: 'Delivery Address',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your delivery address';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.home_outlined),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.phone_outlined),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _notesController,
                labelText: 'Delivery Notes (Optional)',
                keyboardType: TextInputType.multiline,
                prefixIcon: const Icon(Icons.note_outlined),
              ),
              const SizedBox(height: 20),
              _buildPaymentOptions(),
              const SizedBox(height: 20),
              _buildOrderSummary(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2d6a4f),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed:
                      _isSubmitting
                          ? null
                          : () {
                            if (_formKey.currentState!.validate()) {
                              if (_paymentMethod == PaymentMethod.creditCard) {
                                if (_selectedCardType == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a card type',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }
                              _showOrderConfirmationDialog();
                            }
                          },
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Reserve Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
