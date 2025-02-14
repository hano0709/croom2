import 'package:croom2/upgrade_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'roommate_screen.dart';

class PropertyScreen extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic> property;

  PropertyScreen({required this.propertyId, required this.property});

  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? propertyData;
  bool isSaved = false;
  List<Map<String, dynamic>> interestedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
  }

  Future<void> _fetchPropertyDetails() async {
    DocumentSnapshot propertyDoc =
    await _firestore.collection('properties').doc(widget.propertyId).get();

    if (propertyDoc.exists) {
      setState(() {
        propertyData = propertyDoc.data() as Map<String, dynamic>?;
      });
      _checkIfSaved();
      _fetchInterestedUsers();
    }
  }

  Future<void> _fetchInterestedUsers() async {
    List<Map<String, dynamic>> usersList = [];
    try {
      var snapshot = await _firestore.collection('saved_properties').get();

      for (var userDoc in snapshot.docs) {
        var userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey(widget.propertyId)) {
          var userSnapshot = await _firestore.collection('users').doc(userDoc.id).get();
          if (userSnapshot.exists) {
            var user = userSnapshot.data() as Map<String, dynamic>;
            user['userId'] = userDoc.id; // Store user ID for navigation
            usersList.add(user);
          }
        }
      }

      setState(() {
        interestedUsers = usersList;
      });
    } catch (e) {
      print('Error fetching interested users: $e');
    }
  }

  Future<void> _checkIfSaved() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot savedDoc =
      await _firestore.collection('saved_properties').doc(user.uid).get();
      if (savedDoc.exists && savedDoc.data() != null) {
        Map<String, dynamic> savedProperties = savedDoc.data() as Map<String, dynamic>;
        setState(() {
          isSaved = savedProperties.containsKey(widget.propertyId);
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    User? user = _auth.currentUser;
    if (user != null && propertyData != null) {
      if (isSaved) {
        await _firestore.collection('saved_properties').doc(user.uid).update({
          widget.propertyId: FieldValue.delete(),
        });
      } else {
        await _firestore.collection('saved_properties').doc(user.uid).set({
          widget.propertyId: propertyData,
        }, SetOptions(merge: true));
      }
      setState(() {
        isSaved = !isSaved;
      });
      _fetchInterestedUsers(); // Refresh the list after toggling
    }
  }

  Future<bool> _checkCallCredits() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final callsLeft = doc.data()?['calls_left'] ?? 0;

    if (callsLeft <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Calls Left'),
          content: Text('Please purchase more calls to continue.'),
          actions: [
            TextButton(
              child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF6B9080),
                  ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                  'Purchase',
                  style: TextStyle(
                    color: Color(0xFF6B9080),
                  ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpgradeScreen()),
                );
              },
            ),
          ],
        ),
      );
      return false;
    }

    bool confirmCall = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Call'),
        content: Text('You have $callsLeft calls left. Do you want to make this call?'),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF6B9080),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(
              'Call',
              style: TextStyle(
                color: Color(0xFF6B9080),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmCall) return false;

    // Deduct one call
    await _firestore.collection('users').doc(user.uid).update({
      'calls_left': FieldValue.increment(-1)
    });

    return true;
  }

  Future<void> _makeCall(String phoneNumber) async {
    try {
      final Uri callUri = Uri.parse("tel:$phoneNumber");
      final user = _auth.currentUser;

      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not launch call";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making call: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error launching call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Color(0xFF6B9080);
    final Color surface = Color(0xFFF8F9FA);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          propertyData?['title'] ?? 'Property Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: propertyData == null
          ? Center(child: CircularProgressIndicator(color: primary))
          : Container(
        color: surface,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Image
              Container(
                height: 250.0,
                width: double.infinity,
                child: Image.network(
                  propertyData?['imageUrl'] ?? 'https://via.placeholder.com/400x200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price and Save Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. ${propertyData?['price'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleSave,
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Property Details Section
                    _buildSection('Property Details', Icons.home_outlined, primary),
                    _buildDetailTile('Location', propertyData?['location'] ?? 'N/A', Icons.location_on, primary),
                    _buildDetailTile('Type', propertyData?['type'] ?? 'N/A', Icons.apartment, primary),

                    SizedBox(height: 24),

                    // Facilities Section
                    _buildSection('Facilities', Icons.local_offer_outlined, primary),
                    if (propertyData?['facilities'] != null && propertyData!['facilities'] is List)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: List<Widget>.from(
                          (propertyData!['facilities'] as List).map(
                                (facility) => Chip(
                              label: Text(
                                facility,
                                style: TextStyle(color: primary),
                              ),
                              backgroundColor: primary.withOpacity(0.1),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      )
                    else
                      Text('No facilities listed.'),

                    SizedBox(height: 24),

                    // Contact Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String phone = propertyData?['phone'] ?? '';
                          if (phone.isNotEmpty) {
                            // First check if user has available credits
                            final canCall = await _checkCallCredits();
                            if (canCall) {
                              try {
                                await _makeCall(phone);
                              } catch (e) {
                                // If call fails, refund the credit
                                final user = _auth.currentUser;
                                if (user != null) {
                                  await _firestore.collection('users').doc(user.uid).update({
                                    'calls_left': FieldValue.increment(1)
                                  });
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to make call. Credit has been refunded.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Phone number not available'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.call),
                        label: Text(
                          'CONTACT OWNER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Interested Users Section
                    _buildSection('Interested Users', Icons.people_outline, primary),
                    if (interestedUsers.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            'No users have saved this property yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: interestedUsers.length,
                        itemBuilder: (context, index) {
                          final user = interestedUsers[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RoommateScreen(
                                      userId: user['userId'],
                                    ),
                                  ),
                                );
                              },
                              contentPadding: EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                              ),
                              title: Text(
                                user['name'] ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${user['age']} • ${user['college']}',
                                style: TextStyle(color: Colors.black54),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon, Color primary) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}