import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  Future<void> _launchContact(BuildContext context, String contact, bool isPhone) async {
    final Uri uri = isPhone
        ? Uri.parse('tel:$contact')
        : Uri.parse('mailto:$contact');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Color(0xFF6B9080); // Same primary color
    final Color surface = Color(0xFFF8F9FA); // Same background color

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: Container(
        color: surface, // Set background color
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF6B9080), // Primary color
                    child: Icon(
                      Icons.support_agent,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildContactCard(
                  context: context,
                  icon: Icons.phone,
                  title: 'Phone Number',
                  subtitle: '+1 800 123 4567',
                  onTap: () => _launchContact(context, '+1 800 123 4567', true),
                  primary: primary,
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  context: context,
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: 'support@croom.com',
                  onTap: () => _launchContact(context, 'support@croom.com', false),
                  primary: primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primary,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Same border radius
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primary.withOpacity(0.1), // Lighter primary color
          child: Icon(icon, color: primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: primary),
        onTap: onTap,
      ),
    );
  }
}