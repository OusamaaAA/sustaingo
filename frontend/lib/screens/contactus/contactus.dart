import 'package:flutter/material.dart';
import '../../constants.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for modern look
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0, // Remove elevation for flat modern design
        centerTitle: false, // Center title for better balance
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding * 1.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with modern styling
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d6a4f).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contact_support_outlined,
                      size: 40,
                      color: Color(0xFF2d6a4f),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'How can we help you?',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'We\'re here to assist you with any questions\nabout SustainGo and our services',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding * 2),

            // Contact cards with modern styling
            _buildContactInfoCard(
              context: context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'For general inquiries and support',
              detail: 'support@sustaingo.com',
              isLink: true,
              link: 'mailto:support@sustaingo.com',
              iconBackground: Colors.blue[50],
              iconColor: Colors.blue,
            ),
            const SizedBox(height: defaultPadding),

            _buildContactInfoCard(
              context: context,
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '8:00 AM to 4:00 PM, Mon-Fri',
              detail: '+961 1 300 599',
              isLink: true,
              link: 'tel:+9611300599',
              iconBackground: Colors.green[50],
              iconColor: Colors.green,
            ),
            const SizedBox(height: defaultPadding),

            _buildContactInfoCard(
              context: context,
              icon: Icons.location_on_outlined,
              title: 'Our Location',
              subtitle: 'Based in beautiful Beirut',
              detail: 'Beirut, Lebanon',
              iconBackground: Colors.orange[50],
              iconColor: Colors.orange,
            ),
            const SizedBox(height: defaultPadding * 2),

            // About section with modern card
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2d6a4f).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2d6a4f),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: defaultPadding / 2),
                      Text(
                        'About SustainGo',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'SustainGo connects you with local restaurants, cafes, and bakeries in Beirut to offer discounted surplus food, helping reduce waste while providing affordable meals.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'By choosing SustainGo, you contribute to a more sustainable future while enjoying delicious food at great prices.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding * 2),
            // Footer text
            Center(
              child: Text(
                'We appreciate your support!',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
    bool isLink = false,
    String? link,
    Color? iconBackground,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackground ?? const Color(0xFF2d6a4f).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF2d6a4f),
              size: 24,
            ),
          ),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: defaultPadding / 2),
                if (isLink && link != null)
                  InkWell(
                    onTap: () {
                      print('Opening: $link');
                      // launchUrl(Uri.parse(link));
                    },
                    child: Text(
                      detail,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: const Color(0xFF2d6a4f),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
