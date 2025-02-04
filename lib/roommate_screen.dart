import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateScreen extends StatelessWidget {
  final String userId;

  RoommateScreen({required this.userId, required Map<String, dynamic> roommate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: 0, bottom: 16),
                  centerTitle: true,
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 100),
                      Text(
                        roommate['name'] ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(2.0, 2.0),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        roommate['college'] ?? 'Unknown College',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue.shade300, Colors.blue.shade700],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 80,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(
                              roommate['profileImage'] ?? 'https://via.placeholder.com/150',
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionTitle('Basic Details'),
                    _buildDetailCard({
                      'Gender': roommate['gender'] ?? 'Not specified',
                      'Age': roommate['age'] ?? 'Not specified',
                      'Year': roommate['year'] ?? 'Not specified',
                      'Major': roommate['major'] ?? 'Not specified',
                    }),
                    SizedBox(height: 16),
                    _buildSectionTitle('Preferences'),
                    _buildPreferencesCard(roommate['preferences'] ?? 'No preferences specified'),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMessageDialog(context, userId),
        icon: Icon(Icons.message),
        label: Text('Message', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildDetailCard(Map<String, String> details) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: details.entries.map((entry) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.key}:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(entry.value),
                  ],
                ),
              )
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(String preferences) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          preferences,
          style: TextStyle(fontSize: 16),
        ),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () { /* Implement messaging logic */ },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
}