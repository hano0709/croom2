import 'package:croom2/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController preferencesController = TextEditingController();

  String? gender;

  // List of Cloudinary Avatar URLs
  final List<String> avatarUrls = [
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738343894/user8_mc1wb5.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738343894/user9_g0yqm2.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738343893/user7_fa8ayj.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738343893/user6_l4gdxj.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738343893/user4_weh0g9.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738343893/user5_xuct7q.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738340295/user3_s9eb8j.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738340295/user1_l10igo.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738340295/user2_h4pque.jpg',
    'https://res.cloudinary.com/doqo1sf9g/image/upload/v1738340295/user0_n56lbh.jpg',
  ];

  String? _selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firestore if exists
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          emailController.text = userDoc['email'] ?? '';
          phoneController.text = userDoc['phone'] ?? '';
          gender = userDoc['gender'] ?? '';
          ageController.text = userDoc['age'] ?? '';
          collegeController.text = userDoc['college'] ?? '';
          majorController.text = userDoc['major'] ?? '';
          yearController.text = userDoc['year'] ?? '';
          preferencesController.text = userDoc['preferences'] ?? '';
          _selectedAvatarUrl = userDoc['profileImage'] ?? avatarUrls[0]; // Set default if null
        });
      }
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'gender': gender,
          'age': ageController.text,
          'college': collegeController.text,
          'major': majorController.text,
          'year': yearController.text,
          'preferences': preferencesController.text,
          'profileImage': _selectedAvatarUrl,
        });

        // Navigate to Profile Screen after saving
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      resizeToAvoidBottomInset: true, // Ensure layout adjusts with keyboard
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Dismiss keyboard on drag
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image Selection
                Text('Choose a Profile Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                // Wrap the avatar selection with a Wrap widget
                Wrap(
                  spacing: 8.0,  // Horizontal spacing between avatars
                  runSpacing: 8.0,  // Vertical spacing between avatars (if they wrap to the next line)
                  children: avatarUrls.map((url) {
                    bool isSelected = _selectedAvatarUrl == url; // Check if avatar is selected
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarUrl = url;  // Set the selected avatar
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding for spacing
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(url),
                          backgroundColor: Colors.transparent,
                          child: isSelected
                              ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueAccent, // Add a blue border when selected
                                width: 4, // Border width
                              ),
                            ),
                          )
                              : null,  // No decoration when not selected
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),

                // Profile Form
                buildTextField("Name", nameController),
                buildTextField("Email", emailController),
                buildTextField("Phone", phoneController),
                buildGenderSelection(),
                buildTextField("Age", ageController),
                buildTextField("College", collegeController),
                buildTextField("Major", majorController),
                buildTextField("Year", yearController),
                buildTextField("Preferences", preferencesController),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _saveUserData,
                  child: Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: Text('Male'),
              value: 'Male',
              groupValue: gender,
              onChanged: (value) {
                setState(() {
                  gender = value;
                });
              },
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: Text('Female'),
              value: 'Female',
              groupValue: gender,
              onChanged: (value) {
                setState(() {
                  gender = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
