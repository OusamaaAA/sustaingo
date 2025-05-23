import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../entry_point.dart';
import '../home/home_screen.dart';

// Update the constructor to make bagContents optional
// In reservation_confirmation_screen.dart
class ReservationConfirmationScreen extends StatefulWidget {
  final List<String> bagContents;

  const ReservationConfirmationScreen({
    super.key,
    required this.bagContents, // Or make it optional with a default value
  });

  @override
  State<ReservationConfirmationScreen> createState() =>
      _ReservationConfirmationScreenState();
}

// ... (rest of the file remains the same)

class _ReservationConfirmationScreenState
    extends State<ReservationConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _showContents = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Vibrate when opened
    HapticFeedback.mediumImpact();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealContents() {
    setState(() {
      _showContents = true;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child:
              _showContents
                  ? _buildContentsPopup()
                  : _buildInitialConfirmation(),
        ),
      ),
    );
  }

  Widget _buildInitialConfirmation() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: GestureDetector(
          onTap: _revealContents,
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mystery Bag is on the way!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d6a4f),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap the bag to reveal your items',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentsPopup() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.card_giftcard,
                size: 80,
                color: Color(0xFF2d6a4f),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Mystery Bag Contains:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2d6a4f),
                ),
              ),

              //add method api to display mystery bag content
              const SizedBox(height: 20),
              const Text(
                "Don't forget to check the Recipe Generator feature for recipe inspirations!",
                style: TextStyle(
                  fontSize: 15, //
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe41616),
                ),
              ),
              const SizedBox(height: 10),
              ...widget.bagContents
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• $item',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2d6a4f),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const EntryPoint()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Got it!', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
