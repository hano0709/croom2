import 'package:croom2/be_landlord_screen.dart';
import 'package:croom2/chat_dashboard_screen.dart';
import 'package:croom2/contact_us_screen.dart';
import 'package:croom2/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:croom2/upgrade_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'faq_screen.dart';
import 'property_card.dart';
import 'property_screen.dart';
import 'roommate_screen.dart';
import 'saved_properties.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final Color primary = Color(0xFF6B9080);
  final Color surface = Color(0xFFF8F9FA);

  List<Map<String, dynamic>> hostelProperties = [];
  List<Map<String, dynamic>> flatProperties = [];
  List<Map<String, dynamic>> roommates = [];

  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String _sortOrder = 'none';
  List<String> _selectedFacilities = [];
  List<String> _availableFacilities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchProperties();
    fetchRoommates();
  }

  Stream<int> getTotalUnreadCount() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lastMessageSenderId = data['lastMessageSenderId'];
        if (lastMessageSenderId != currentUser.uid) {
          total += (data['unreadCount'] ?? 0) as int;
        }
      }
      return total;
    });
  }

  int _parsePrice(String price) {
    final numericString = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericString) ?? 0;
  }

  Future<void> fetchProperties() async {
    var hostelSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('type', isEqualTo: 'hostel')
        .get();

    var flatSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('type', isEqualTo: 'flat')
        .get();

    final allFacilities = <String>{};
    hostelSnapshot.docs.forEach((doc) => allFacilities.addAll(List<String>.from(doc['facilities'] ?? [])));
    flatSnapshot.docs.forEach((doc) => allFacilities.addAll(List<String>.from(doc['facilities'] ?? [])));

    setState(() {
      hostelProperties = hostelSnapshot.docs.map((doc) => {
        'propertyId': doc.id,
        'title': doc['title'] ?? 'No Title',
        'price': doc['price'] ?? 'Price Not Available',
        'location': doc['location'] ?? 'Location Not Specified',
        'imageUrl': doc['imageUrl'] ?? 'https://via.placeholder.com/150',
        'facilities': doc['facilities'] ?? [],
      }).toList();

      flatProperties = flatSnapshot.docs.map((doc) => {
        'propertyId': doc.id,
        'title': doc['title'] ?? 'No Title',
        'price': doc['price'] ?? 'Price Not Available',
        'location': doc['location'] ?? 'Location Not Specified',
        'imageUrl': doc['imageUrl'] ?? 'https://via.placeholder.com/150',
        'facilities': doc['facilities'] ?? [],
      }).toList();

      _availableFacilities = allFacilities.toList()..sort();
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sort By', style: TextStyle(color: primary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Price: Low to High'),
                leading: Radio(
                  value: 'lowToHigh',
                  groupValue: _sortOrder,
                  onChanged: (String? value) {
                    setState(() => _sortOrder = value!);
                    Navigator.pop(context);
                  },
                  activeColor: primary, // Use primary color
                ),
              ),
              ListTile(
                title: Text('Price: High to Low'),
                leading: Radio(
                  value: 'highToLow',
                  groupValue: _sortOrder,
                  onChanged: (String? value) {
                    setState(() => _sortOrder = value!);
                    Navigator.pop(context);
                  },
                  activeColor: primary, // Use primary color
                ),
              ),
              ListTile(
                title: Text('None'),
                leading: Radio(
                  value: 'none',
                  groupValue: _sortOrder,
                  onChanged: (String? value) {
                    setState(() => _sortOrder = value!);
                    Navigator.pop(context);
                  },
                  activeColor: primary, // Use primary color
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Filter by Facilities',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _availableFacilities.length,
                      itemBuilder: (context, index) {
                        final facility = _availableFacilities[index];
                        return CheckboxListTile(
                          title: Text(facility),
                          value: _selectedFacilities.contains(facility),
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value!) {
                                _selectedFacilities.add(facility);
                              } else {
                                _selectedFacilities.remove(facility);
                              }
                            });
                          },
                          activeColor: primary, // Use primary color for checkboxes
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedFacilities.clear());
                          Navigator.pop(context);
                        },
                        child: Text('Reset', style: TextStyle(color: Colors.red)),
                      ),
                      SizedBox(width: 16), // Add spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: Text('Apply', style: TextStyle(color: Colors.white)), // Set text color to white
                        style: ElevatedButton.styleFrom(backgroundColor: primary), // Match background color
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> getFilteredHostels() {
    List<Map<String, dynamic>> filtered = hostelProperties.where((hostel) {
      final matchesSearch = hostel['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hostel['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      final hasFacilities = _selectedFacilities.every((f) =>
      (hostel['facilities'] as List?)?.contains(f) ?? false);
      return matchesSearch && hasFacilities;
    }).toList();

    if (_sortOrder == 'lowToHigh') {
      filtered.sort((a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])));
    } else if (_sortOrder == 'highToLow') {
      filtered.sort((b, a) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])));
    }

    return filtered;
  }

  List<Map<String, dynamic>> getFilteredFlats() {
    List<Map<String, dynamic>> filtered = flatProperties.where((flat) {
      final matchesSearch = flat['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          flat['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      final hasFacilities = _selectedFacilities.every((f) =>
      (flat['facilities'] as List?)?.contains(f) ?? false);
      return matchesSearch && hasFacilities;
    }).toList();

    if (_sortOrder == 'lowToHigh') {
      filtered.sort((a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])));
    } else if (_sortOrder == 'highToLow') {
      filtered.sort((b, a) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])));
    }

    return filtered;
  }

  Future<void> fetchRoommates() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> fetchedRoommates = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {'userId': doc.id, ...data};
      }).toList();

      if (mounted) {
        setState(() {
          roommates = fetchedRoommates;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching roommates: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text('CROOM',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.sort, color: primary),
              onPressed: _showSortDialog
          ),
          IconButton(
              icon: Icon(Icons.filter_list, color: primary),
              onPressed: _showFilterDialog
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.chat, color: primary),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatDashboardScreen()),
                ),
              ),
              StreamBuilder<int>(
                stream: getTotalUnreadCount(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 0) {
                    return SizedBox.shrink();
                  }
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${snapshot.data}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
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
          indicatorColor: primary,
          labelColor: primary,
          unselectedLabelColor: Colors.black54,
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
              decoration: BoxDecoration(color: primary),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.person, color: primary),
              title: Text('Profile'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: primary),
              title: Text('Saved Property'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SavedPropertiesScreen())),
            ),
            ListTile(
              leading: Icon(Icons.arrow_upward, color: primary),
              title: Text('Upgrade'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpgradeScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.help, color: primary),
              title: Text('FAQ'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FAQScreen())),
            ),
            ListTile(
              leading: Icon(Icons.contact_mail, color: primary),
              title: Text('Contact Us'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsScreen())),
            ),
            ListTile(
              leading: Icon(Icons.work, color: primary),
              title: Text('Be a Landlord'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BeLandlordScreen())),
            ),
          ],
        ),
      ),
      body: Container(
        color: surface,
        child: Column(
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search, color: primary),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RefreshIndicator(
                      onRefresh: fetchProperties,
                      child: ListView.builder(
                        itemCount: getFilteredHostels().length,
                        itemBuilder: (context, index) {
                          final hostel = getFilteredHostels()[index];
                          return GestureDetector(
                            onTap: () {
                              if (hostel['propertyId'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyScreen(
                                      propertyId: hostel['propertyId'],
                                      property: hostel,
                                    ),
                                  ),
                                );
                              } else {
                                // Handle the case where propertyId is null
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Property ID is missing')),
                                );
                              }
                            },
                            child: PropertyCard(
                              title: hostel['title'] ?? 'No Title',
                              price: hostel['price'] ?? 'Price Not Available',
                              location: hostel['location'] ?? 'Location Not Specified',
                              imageUrl: hostel['imageUrl'] ?? 'https://via.placeholder.com/150',
                            ),
                          );
                        },
                      ),
                  ),


                  RefreshIndicator(
                      onRefresh: fetchProperties,
                      child: ListView.builder(
                        itemCount: getFilteredFlats().length,
                        itemBuilder: (context, index) {
                          final flat = getFilteredFlats()[index];
                          return GestureDetector(
                            onTap: () {
                              if (flat['propertyId'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyScreen(
                                      propertyId: flat['propertyId'],
                                      property: flat,
                                    ),
                                  ),
                                );
                              } else {
                                // Handle the case where propertyId is null
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Property ID is missing')),
                                );
                              }
                            },
                            child: PropertyCard(
                              title: flat['title'] ?? 'No Title',
                              price: flat['price'] ?? 'Price Not Available',
                              location: flat['location'] ?? 'Location Not Specified',
                              imageUrl: flat['imageUrl'] ?? 'https://via.placeholder.com/150',
                            ),
                          );
                        },
                      ),
                  ),


                  RefreshIndicator(
                    onRefresh: fetchRoommates,
                    child: _isLoading
                        ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: CircularProgressIndicator(color: primary),
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: getFilteredRoommates().length,
                      itemBuilder: (context, index) {
                        final roommate = getFilteredRoommates()[index];
                        return GestureDetector(
                          onTap: () {
                            if (roommate['userId'] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoommateScreen(userId: roommate['userId']),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User ID is missing')),
                              );
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.all(8),
                            elevation: 3,
                            color: Color(0xFFF8F9FA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    roommate['profileImage'] ?? 'https://via.placeholder.com/150'),
                              ),
                              title: Text(roommate['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${roommate['age']} • ${roommate['college']}'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primary),
                            ),
                          ),
                        );
                      },
                    ),
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
