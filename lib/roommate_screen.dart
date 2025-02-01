import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateScreen extends StatelessWidget {
  final String userId;

  RoommateScreen({required this.userId, required Map<String, dynamic> roommate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Roommate Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Roommate data not found'));
          }

          var roommate = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(roommate['profileImage'] ?? 'https://via.placeholder.com/150'),
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: Text(
                    roommate['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.0),
                Center(
                  child: Text(
                    roommate['college'] ?? 'Unknown College',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                Divider(height: 32.0),
                Text('Basic Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildDetailRow('Gender', roommate['gender'] ?? 'Not specified'),
                _buildDetailRow('Age', roommate['age'] ?? 'Not specified'),
                _buildDetailRow('Year', roommate['year'] ?? 'Not specified'),
                _buildDetailRow('Major', roommate['major'] ?? 'Not specified'),
                Divider(height: 32.0),
                Text('Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.0),
                Text(roommate['preferences'] ?? 'No preferences specified', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => _showMessageDialog(context, userId),
          icon: Icon(Icons.message),
          label: Text('Message'),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message Roommate'),
          content: Text('Send a message to this roommate.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
            TextButton(onPressed: () { /* Implement messaging logic */ }, child: Text('Send')),
          ],
        );
      },
    );
  }
}
