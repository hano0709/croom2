import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BeLandlordScreen extends StatelessWidget {
  const BeLandlordScreen({Key? key}) : super(key: key);

  Future<void> _launchWebsite(BuildContext context) async {
    final Uri uri = Uri.parse('https://croom-web.onrender.com');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF6B9080);
    final Color surface = const Color(0xFFF8F9FA);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Be a Landlord',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: Container(
        color: surface,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF6B9080),
              child: Icon(
                Icons.business,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary.withOpacity(0.1),
                  child: Icon(Icons.open_in_browser, color: primary),
                ),
                title: const Text(
                  'Visit Our Website',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  'croom-web.onrender.com',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: primary),
                onTap: () => _launchWebsite(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}