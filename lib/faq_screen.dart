import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color primary = Color(0xFF6B9080); // Same primary color
    final Color surface = Color(0xFFF8F9FA); // Same background color

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: Container(
        color: surface, // Set background color
        child: Padding(
          padding: EdgeInsets.all(24.0), // Consistent padding
          child: ListView(
            children: [
              // Problem Statement Section
              Text(
                'Problem Statement',
                style: TextStyle(
                  fontSize: 24, // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: primary, // Use primary color
                ),
              ),
              SizedBox(height: 16), // Consistent spacing
              Text(
                'A solution for college students to find hostels/flats/roommates',
                style: TextStyle(
                  fontSize: 16, // Adjusted font size
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24), // Consistent spacing
              Divider(color: Colors.grey[300]), // Subtle divider color
              SizedBox(height: 24), // Consistent spacing

              // Team Members Section
              Text(
                'Team Members',
                style: TextStyle(
                  fontSize: 24, // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: primary, // Use primary color
                ),
              ),
              SizedBox(height: 16), // Consistent spacing
              // Bullet points for team members
              BulletPoint(text: 'Hano Joby Varghese', primary: primary),
              BulletPoint(text: 'Atul Sangale', primary: primary),
              BulletPoint(text: 'Ayush', primary: primary),
              BulletPoint(text: 'Ruhan Dave', primary: primary),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Bullet Point Widget
class BulletPoint extends StatelessWidget {
  final String text;
  final Color primary;

  BulletPoint({required this.text, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Consistent padding
      child: Row(
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 16, // Adjusted bullet point size
            color: primary, // Use primary color
          ),
          SizedBox(width: 12), // Consistent spacing
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16, // Adjusted font size
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}