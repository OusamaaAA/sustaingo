import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// The main screen widget for the FAQ bot.
class FAQBotScreen extends StatefulWidget {
  const FAQBotScreen({super.key});

  @override
  State<FAQBotScreen> createState() => _FAQBotScreenState();
}

class _FAQBotScreenState extends State<FAQBotScreen> {
  final TextEditingController _queryController = TextEditingController(); // To control text input
  List<ChatMessage> _messages = []; // Stores chat messages between user and bot
  final String _botName = "SustainBot"; // Bot name shown in UI

  // Color scheme
  final Color _primaryColor = const Color(0xFF2d6a4f);
  final Color _accentColor = const Color(0xFF68C97F);
  final Color _userMessageBackgroundColor = const Color(0xFFDCE775);
  final Color _botMessageBackgroundColor = const Color(0xFF81D4FA);
  final Color _userTextColor = Colors.black87;
  final Color _botTextColor = Colors.white;

  // Font sizes
  final double _messageFontSize = 16.0;
  final double _faqFontSize = 14.0;

  // FAQ styles
  final Color _faqBackgroundColor = Colors.white;
  final Color _faqTextColor = Colors.black87;
  final Color _faqHeaderColor = const Color(0xFF4CAF50);

  // Predefined FAQ list (used in dropdown)
  final List<FAQItem> _faqItems = [
    FAQItem(question: "How does your app help reduce food waste?"),
    FAQItem(question: "What types of food can I find on SustainGo?"),
    FAQItem(question: "How do I place an order?"),
    FAQItem(question: "What areas do you deliver to?"),
    FAQItem(question: "How can I contact customer support?"),
    FAQItem(question: "What is a 'Mystery Bag'?"),
    FAQItem(question: "Are the prices discounted?"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.restaurant_outlined, color: Colors.white),
            const SizedBox(width: 8.0),
            Text(_botName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        backgroundColor: _primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_faqItems.isNotEmpty ? 1 : 0), // Add extra widget if FAQs exist
              itemBuilder: (context, index) {
                if (_faqItems.isNotEmpty && index == 0) {
                  return _buildFAQDropdown(); // Show FAQ dropdown at the top
                } else {
                  final messageIndex = _faqItems.isNotEmpty ? index - 1 : index;
                  final message = _messages[messageIndex];
                  return ChatBubble(
                    text: message.text,
                    isUser: message.isUser,
                    color: message.isUser ? _userMessageBackgroundColor : _botMessageBackgroundColor,
                    textColor: message.isUser ? _userTextColor : _botTextColor,
                    fontSize: _messageFontSize,
                  );
                }
              },
            ),
          ),
          _buildInputArea(), // Message input field
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  // Builds the expandable FAQ section
  Widget _buildFAQDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: _faqBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: _faqFontSize,
            fontWeight: FontWeight.bold,
            color: _faqHeaderColor,
          ),
        ),
        children: _faqItems
            .map((faqItem) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      _sendMessage(faqItem.question); // Send question on tap
                    },
                    child: Text(
                      faqItem.question,
                      style: TextStyle(
                        fontSize: _faqFontSize,
                        fontWeight: FontWeight.w500,
                        color: _faqTextColor,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Message input section with send button
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4.0,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _queryController,
              style: TextStyle(fontSize: _messageFontSize),
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: _primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              onSubmitted: (value) {
                _sendMessage(value); // Submit message on enter key
              },
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: _accentColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                _sendMessage(_queryController.text); // Send message on button press
              },
            ),
          ),
        ],
      ),
    );
  }

  // Sends a user message and triggers API call
  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: text, isUser: true));
        _queryController.clear();
      });
      _askQuestion(text); // Call backend
    }
  }

  // Makes HTTP request to FastAPI backend with user question
  void _askQuestion(String query) async {
    final url = Uri.parse('https://faqbot-backend.onrender.com/ask?question=${Uri.encodeComponent(query)}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String botResponse = 'Sorry, I couldn\'t find an answer.';
        if (data['suggestions'] != null && data['suggestions'].isNotEmpty) {
          botResponse = data['suggestions'][0]['answer'];
        } else if (data['answer'] != null) {
          botResponse = data['answer'];
        }
        _addBotMessage(botResponse); // Show bot's reply
      } else {
        _addBotMessage('Server error. Please try again later.');
      }
    } catch (e) {
      _addBotMessage('Failed to connect to FAQ service.');
    }
  }

  // Appends a bot response to the chat
  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
  }
}

// Model class for an FAQ item
class FAQItem {
  final String question;

  FAQItem({required this.question});
}

// Model class representing a single message in chat
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

// Custom widget for displaying user/bot messages as chat bubbles
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color color;
  final Color textColor;
  final double fontSize;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.color,
    required this.textColor,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      ),
    );
  }
}

// Terminal command notes (useful reminders for dev):
// To run FastAPI server: uvicorn faqapi:app --host 0.0.0.0 --port 60165 --reload
// To test API: visit http://192.168.1.6:60165/docs#/
