import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Problem Statement Section
            Text(
              'Problem Statement',
              style: TextStyle(
                fontSize: 26, // Increased font size for the main topic
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'A solution for college students to find hostels/flats/roommates',
              style: TextStyle(
                fontSize: 18, // Increased font size for description
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.black), // Line separator after problem statement
            SizedBox(height: 30), // Increased space after divider

            // Team Members Section
            Text(
              'Team Members',
              style: TextStyle(
                fontSize: 26, // Increased font size for the main topic
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20), // Increased spacing for team members
            // Bullet points for team members with more spacing
            BulletPoint(text: 'Hano Joby Varghese'),
            BulletPoint(text: 'Atul Sangale'),
            BulletPoint(text: 'Ayush'),
            BulletPoint(text: 'Ruhan Dave'),
          ],
        ),
      ),
    );
  }
}

// Custom Bullet Point Widget
class BulletPoint extends StatelessWidget {
  final String text;
  BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Added padding for more space
      child: Row(
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 20, // Increased bullet point size to 16
            color: Colors.blue, // Bullet point color
          ),
          SizedBox(width: 12), // Increased space between bullet and text
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18, // Increased font size for team members
              ),
            ),
          ),
        ],
      ),
    );
  }
}
