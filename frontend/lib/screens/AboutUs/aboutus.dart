import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG logos and illustrations
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

/// About Us Screen for the SustainGo app
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  // Function to launch URL
  void _launchURL() async {
    final Uri url = Uri.parse('https://sustaingo.tiiny.site/index.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Section
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Main Content Area
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo Section
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.asset('assets/images/sustainlogo.png'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // App Name
            Text(
              'SustainGo',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24.0),

            // Our Mission Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.flag_outlined, color: Color(0xFF2d6a4f)),
                        SizedBox(width: 8.0),
                        Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'At SustainGo, our mission is to revolutionize how we approach food consumption by seamlessly connecting individuals with delightful, surplus food from local restaurants and businesses. We firmly believe that no perfectly edible food should ever be discarded. Through our innovative platform, we aim to foster a more sustainable and equitable food ecosystem, benefiting both our community and the planet.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Our Vision Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.visibility_outlined,
                          color: Color(0xFF2d6a4f),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Our Vision',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'We envision a future where the value of food is deeply appreciated, resources are utilized with utmost efficiency, and access to nutritious meals is a reality for everyone. By cultivating strong collaborations among food providers, conscious consumers, and dedicated NGOs across Lebanon, we are committed to minimizing our collective environmental footprint and contributing to a more food-secure and thriving society.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Connect With Us Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.email_rounded, color: Color(0xFF2d6a4f)),
                        SizedBox(width: 8.0),
                        Text(
                          'Connect With Us',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Your feedback, inquiries, and potential partnership proposals are invaluable to us. Please don\'t hesitate to reach out through the following channel:',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    const Center(
                      child: Text(
                        'support@sustaingo.com',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Join Us Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.group_add_outlined,
                          color: Color(0xFF2d6a4f),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Join Us',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Want to make an impact? Join our mission as a vendor or NGO partner by filling out this quick survey!',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(
                          'https://sustaingo.tiiny.site/index.html',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: const Text(
                        'https://sustaingo.tiiny.site/index.html',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // Footer Section
            Text(
              'SustainGo © ${DateTime.now().year}',
              style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
            ),
          ],
        ),
      ),

      // Background Color
      backgroundColor: Colors.grey[100],
    );
  }
}
