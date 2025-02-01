import 'package:croom2/contact_us_screen.dart';
import 'package:croom2/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'faq_screen.dart'; // Import FAQScreen
import 'property_card.dart'; // Import PropertyCard widget
import 'property_screen.dart'; // Import PropertyScreen
import 'roommate_screen.dart'; // Import RoommateScreen
import 'saved_properties.dart'; // Import SavedPropertiesScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Firestore data lists
  List<Map<String, dynamic>> hostelProperties = [];
  List<Map<String, dynamic>> flatProperties = [];
  List<Map<String, dynamic>> roommates = [];

  bool _isLoading = true; // Loading state for roommates

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchProperties();
    fetchRoommates();
  }

  // Fetch properties from Firestore
  Future<void> fetchProperties() async {
    // Fetch hostel properties
    var hostelSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('type', isEqualTo: 'hostel')
        .get();

    // Fetch flat properties
    var flatSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('type', isEqualTo: 'flat')
        .get();

    setState(() {
      hostelProperties = hostelSnapshot.docs
          .map((doc) => {
        'propertyId': doc.id,
        'title': doc['title'],
        'price': doc['price'],
        'location': doc['location'],
        'imageUrl': doc['imageUrl'],
      })
          .toList();

      flatProperties = flatSnapshot.docs
          .map((doc) => {
        'propertyId': doc.id,
        'title': doc['title'],
        'price': doc['price'],
        'location': doc['location'],
        'imageUrl': doc['imageUrl'],
      })
          .toList();
    });
  }

  // Fetch roommates data from Firestore
  Future<void> fetchRoommates() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> fetchedRoommates = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'userId': doc.id,
          ...data,
        };
      }).toList();

      if (mounted) {
        setState(() {
          roommates = fetchedRoommates;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching roommates: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CROOM'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Hostel'),
            Tab(text: 'Flats'),
            Tab(text: 'Roommates'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Saved Property'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedPropertiesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_upward),
              title: Text('Upgrade'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('FAQ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactUsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: hostelProperties.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyScreen(
                        propertyId: hostelProperties[index]['propertyId']!,
                        property: hostelProperties[index],
                      ),
                    ),
                  );
                },
                child: PropertyCard(
                  title: hostelProperties[index]['title']!,
                  price: hostelProperties[index]['price']!,
                  location: hostelProperties[index]['location']!,
                  imageUrl: hostelProperties[index]['imageUrl']!,
                ),
              );
            },
          ),
          ListView.builder(
            itemCount: flatProperties.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyScreen(
                        propertyId: flatProperties[index]['propertyId']!,
                        property: flatProperties[index],
                      ),
                    ),
                  );
                },
                child: PropertyCard(
                  title: flatProperties[index]['title']!,
                  price: flatProperties[index]['price']!,
                  location: flatProperties[index]['location']!,
                  imageUrl: flatProperties[index]['imageUrl']!,
                ),
              );
            },
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: roommates.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoommateScreen(
                        userId: roommates[index]['userId']!,
                        roommate: roommates[index],
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(roommates[index]['profileImage'] ??
                          'https://via.placeholder.com/150'),
                    ),
                    title: Text(roommates[index]['name'] ?? 'Unknown'),
                    subtitle: Text('${roommates[index]['age']} • ${roommates[index]['college']}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
