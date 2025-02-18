import 'package:croom2/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateScreen extends StatelessWidget {
  final String userId;
  final Color primary = Color(0xFF6B9080);
  final Color surface = Color(0xFFF8F9FA);

  RoommateScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Roommate data not found'));
          }

          var roommate = snapshot.data!.data() as Map<String, dynamic>;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 230,
                pinned: true,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: surface,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 80,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: primary,
                            child: CircleAvatar(
                              radius: 76,
                              backgroundImage: NetworkImage(
                                roommate['profileImage'] ?? 'https://via.placeholder.com/150',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 0), // Adjust spacing
                    Text(
                      roommate['name'] ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      roommate['college'] ?? 'Unknown College',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionTitle('Basic Details'),
                    SizedBox(height: 16),
                    _buildDetailCard({
                      'Gender': roommate['gender'] ?? 'Not specified',
                      'Age': roommate['age'] ?? 'Not specified',
                      'Year': roommate['year'] ?? 'Not specified',
                      'Major': roommate['major'] ?? 'Not specified',
                    }),
                    SizedBox(height: 24),
                    _buildSectionTitle('Preferences'),
                    SizedBox(height: 16),
                    _buildPreferencesCard(roommate['preferences'] ?? 'No preferences specified'),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Container();
          }

          var roommate = snapshot.data!.data() as Map<String, dynamic>;
          return FloatingActionButton.extended(
            onPressed: () => _showMessageDialog(
                context,
                userId,
                roommate['name'] ?? 'Roommate'
            ),
            icon: Icon(Icons.message, color: Colors.white),
            label: Text('Message', style: TextStyle(color: Colors.white)),
            backgroundColor: primary,
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primary, size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(Map<String, String> details) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: details.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry.key}:',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54
                  ),
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(String preferences) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          preferences,
          style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context, String roomateId, String roommateName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
            roomateId: roomateId,
            roommateName: roommateName
        ),
      ),
    );
  }
}