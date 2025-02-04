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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue,
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
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                context: context,
                icon: Icons.email,
                title: 'Email',
                subtitle: 'support@croom.com',
                onTap: () => _launchContact(context, 'support@croom.com', false),
              ),
            ],
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
