import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for user ID
import 'package:croom2/property_screen.dart'; // Import PropertyScreen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedPropertiesScreen extends StatefulWidget {
  @override
  _SavedPropertiesScreenState createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  List<Map<String, dynamic>> savedProperties = [];

  @override
  void initState() {
    super.initState();
    fetchSavedProperties();
  }

  // Fetch saved properties from Firestore
  Future<void> fetchSavedProperties() async {
    try {
      // Get the current user ID
      var userId = FirebaseAuth.instance.currentUser!.uid; // Fetch actual user ID from FirebaseAuth

      // Fetch the saved properties document for this user
      var snapshot = await FirebaseFirestore.instance
          .collection('saved_properties')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data()!;

        // Convert the saved properties into a list of maps with explicit type casting
        setState(() {
          savedProperties = data.entries.map((entry) {
            return {
              'propertyId': entry.key,
              ...Map<String, dynamic>.from(entry.value), // Ensure the value is cast to Map<String, dynamic>
            };
          }).toList();
        });
      } else {
        print('No saved properties found.');
      }
    } catch (e) {
      print('Error fetching saved properties: $e');
    }
  }

  // Remove a property from saved properties
  Future<void> removeProperty(String propertyId) async {
    try {
      // Get the current user ID
      var userId = FirebaseAuth.instance.currentUser!.uid;

      // Reference to the saved properties document for this user
      var userRef = FirebaseFirestore.instance.collection('saved_properties').doc(userId);

      // Check if the user document exists
      var userDoc = await userRef.get();
      if (userDoc.exists) {
        // Remove the property from saved properties
        await userRef.update({
          propertyId: FieldValue.delete(),
        });

        // Update the UI by removing the property from the local list
        setState(() {
          savedProperties.removeWhere((property) => property['propertyId'] == propertyId);
        });
      }
    } catch (e) {
      print('Error removing property: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Properties'),
      ),
      body: savedProperties.isEmpty
          ? Center(child: Text('No saved properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)))
          : ListView.builder(
        itemCount: savedProperties.length,
        itemBuilder: (context, index) {
          var property = savedProperties[index];
          return GestureDetector(
            onTap: () {
              // Navigate to PropertyScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyScreen(
                    propertyId: property['propertyId']!,
                    property: property,
                  ),
                ),
              ).then((_) {
                // Refresh saved properties after returning from PropertyScreen
                fetchSavedProperties();
              });
            },
            child: Card(
              margin: EdgeInsets.all(8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  // Full-width property image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      property['imageUrl'],
                      width: double.infinity,
                      height: 200, // Adjust this value as needed
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Property details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(property['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text('Price: ${property['price']}'),
                              SizedBox(height: 5),
                              Text('Location: ${property['location']}'),
                            ],
                          ),
                        ),
                        // Delete icon aligned to the right of the row
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Remove the property from saved
                            removeProperty(property['propertyId']);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
