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

  // Search functionality variables
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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

  // Method to filter hostel properties based on search query
  List<Map<String, dynamic>> getFilteredHostels() {
    return hostelProperties.where((hostel) {
      return hostel['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hostel['location'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Method to filter flat properties based on search query
  List<Map<String, dynamic>> getFilteredFlats() {
    return flatProperties.where((flat) {
      return flat['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          flat['location'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Method to filter roommates based on search query
  List<Map<String, dynamic>> getFilteredRoommates() {
    return roommates.where((roommate) {
      return roommate['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          roommate['college'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          roommate['year'].toString().contains(_searchQuery) ||
          roommate['major'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Color(0xFF6B9080); // Same primary color
    final Color surface = Color(0xFFF8F9FA); // Same background color

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CROOM',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
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
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary, // Use primary color for tab indicator
          labelColor: primary, // Use primary color for selected tab text
          unselectedLabelColor: Colors.black54, // Use grey for unselected tabs
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
              decoration: BoxDecoration(color: primary), // Use primary color
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: primary),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: primary),
              title: Text('Saved Property'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedPropertiesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_upward, color: primary),
              title: Text('Upgrade'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help, color: primary),
              title: Text('FAQ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail, color: primary),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactUsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: primary),
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Container(
        color: surface, // Set background color
        child: Column(
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search, color: primary),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: _isSearching ? getFilteredHostels().length : hostelProperties.length,
                    itemBuilder: (context, index) {
                      final hostel = _isSearching ? getFilteredHostels()[index] : hostelProperties[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyScreen(
                                propertyId: hostel['propertyId']!,
                                property: hostel,
                              ),
                            ),
                          );
                        },
                        child: PropertyCard(
                          title: hostel['title']!,
                          price: hostel['price']!,
                          location: hostel['location']!,
                          imageUrl: hostel['imageUrl']!,
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: _isSearching ? getFilteredFlats().length : flatProperties.length,
                    itemBuilder: (context, index) {
                      final flat = _isSearching ? getFilteredFlats()[index] : flatProperties[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyScreen(
                                propertyId: flat['propertyId']!,
                                property: flat,
                              ),
                            ),
                          );
                        },
                        child: PropertyCard(
                          title: flat['title']!,
                          price: flat['price']!,
                          location: flat['location']!,
                          imageUrl: flat['imageUrl']!,
                        ),
                      );
                    },
                  ),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: primary))
                      : ListView.builder(
                    itemCount: _isSearching ? getFilteredRoommates().length : roommates.length,
                    itemBuilder: (context, index) {
                      final roommate = _isSearching ? getFilteredRoommates()[index] : roommates[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoommateScreen(
                                userId: roommate['userId']!,
                                roommate: roommate,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.all(8),
                          elevation: 3,
                          color: Color(0xFFF8F9FA), // Set the background color here
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  roommate['profileImage'] ?? 'https://via.placeholder.com/150'),
                            ),
                            title: Text(
                              roommate['name'] ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${roommate['age']} • ${roommate['college']}'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primary),
                          ),
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
    );
  }
}