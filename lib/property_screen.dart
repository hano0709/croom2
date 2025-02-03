import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyScreen extends StatefulWidget {
  final String propertyId;

  PropertyScreen({required this.propertyId, required Map<String, dynamic> property});

  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? propertyData;
  bool isSaved = false;  // Track if property is saved
  List<Map<String, dynamic>> interestedUsers = []; // Store interested users

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
        propertyData = propertyDoc.data() as Map<String, dynamic>?;  // Fetch property data
      });
      _checkIfSaved();  // Check if the property is saved
      _fetchInterestedUsers();  // Fetch interested users
    }
  }

  Future<void> _fetchInterestedUsers() async {
    List<Map<String, dynamic>> usersList = [];
    try {
      // Query saved_properties collection to find users who saved this property
      var snapshot = await _firestore.collection('saved_properties').get();

      for (var userDoc in snapshot.docs) {
        var userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey(widget.propertyId)) {
          // User has saved this property, now fetch their details from the 'users' collection
          var userSnapshot = await _firestore.collection('users').doc(userDoc.id).get();
          if (userSnapshot.exists) {
            var user = userSnapshot.data() as Map<String, dynamic>;
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
        if (savedProperties.containsKey(widget.propertyId)) {
          setState(() {
            isSaved = true;
          });
        }
      }
    }
  }

  void _toggleSave() async {
    User? user = _auth.currentUser;
    if (user != null && propertyData != null) {
      if (isSaved) {
        // Unsaving the property
        await _firestore.collection('saved_properties').doc(user.uid).update({
          widget.propertyId: FieldValue.delete(),
        });
      } else {
        // Saving the property
        await _firestore.collection('saved_properties').doc(user.uid).set({
          widget.propertyId: propertyData,
        }, SetOptions(merge: true));
      }
      setState(() {
        isSaved = !isSaved;
      });
    }
  }

  void _makeCall(String phoneNumber) async {
    final Uri callUri = Uri.parse("tel:$phoneNumber");

    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch call");
      }
    } catch (e) {
      print("Error launching call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(propertyData?['title'] ?? 'Property Details'),
      ),
      body: propertyData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200.0,
              child: PageView(
                children: [
                  Image.network(
                    propertyData?['imageUrl'] ?? 'https://via.placeholder.com/400x200',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text('Image not available'));
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: ${propertyData?['location'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Type: ${propertyData?['type'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Price: ${propertyData?['price'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700], // Highlighted in dark green
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleSave,
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.red : Colors.grey,
                  ),
                  label: Text(
                    isSaved ? "Saved" : "Save for Later",
                    style: TextStyle(color: isSaved ? Colors.red : Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: isSaved ? Colors.white : Colors.red,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    String phone = propertyData?['phone'] ?? '';
                    if (phone.isNotEmpty) {
                      _makeCall(phone);
                    } else {
                      print("Phone number is not available.");
                    }
                  },
                  icon: Icon(Icons.call),
                  label: Text("Call"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 32.0),
            Text(
              'Facilities:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            if (propertyData?['facilities'] != null && propertyData!['facilities'] is List)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List<Widget>.from(
                  (propertyData!['facilities'] as List).map(
                        (facility) => Chip(
                      label: Text(
                        facility,
                        style: TextStyle(fontSize: 14.0),
                      ),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                ),
              )
            else
              Text('No facilities listed.'),
            Divider(height: 32.0),
            Text(
              'Interested Users:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            if (interestedUsers.isEmpty)
              Text('No users have saved this property.')
            else
              Column(
                children: interestedUsers.map((user) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                      ),
                      title: Text(user['name'] ?? 'Unknown'),
                      subtitle: Text(user['college'] ?? 'Unknown'),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
