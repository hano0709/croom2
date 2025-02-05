import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController ageController;
  late TextEditingController collegeController;
  late TextEditingController majorController;
  late TextEditingController yearController;
  late TextEditingController preferencesController;

  String? gender;
  String? _selectedAvatarUrl;

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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    ageController = TextEditingController();
    collegeController = TextEditingController();
    majorController = TextEditingController();
    yearController = TextEditingController();
    preferencesController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          emailController.text = userDoc['email'] ?? '';
          phoneController.text = userDoc['phone'] ?? '';
          gender = userDoc['gender'];
          ageController.text = userDoc['age'] ?? '';
          collegeController.text = userDoc['college'] ?? '';
          majorController.text = userDoc['major'] ?? '';
          yearController.text = userDoc['year'] ?? '';
          preferencesController.text = userDoc['preferences'] ?? '';
          _selectedAvatarUrl = userDoc['profileImage'] ?? avatarUrls[0];
        });
      }
    }
  }

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    collegeController.dispose();
    majorController.dispose();
    yearController.dispose();
    preferencesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Color(0xFF6B9080);
    final Color surface = Color(0xFFF8F9FA);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: Container(
        color: surface,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarGrid(primary),
                SizedBox(height: 32),
                _buildSection('Personal Information', Icons.person_outline, primary),
                _buildTextField(nameController, 'Full Name', Icons.person, primary),
                _buildTextField(emailController, 'Email', Icons.email, primary),
                _buildTextField(phoneController, 'Phone', Icons.phone, primary),
                _buildGenderPicker(primary),
                _buildTextField(ageController, 'Age', Icons.cake, primary),

                SizedBox(height: 24),
                _buildSection('Education', Icons.school_outlined, primary),
                _buildTextField(collegeController, 'College', Icons.school, primary),
                _buildTextField(majorController, 'Major', Icons.work, primary),
                _buildTextField(yearController, 'Year', Icons.calendar_today, primary),

                SizedBox(height: 24),
                _buildSection('Preferences', Icons.favorite_outline, primary),
                _buildTextField(preferencesController,
                    'Roommate Preferences', Icons.favorite, primary),

                // Save button at the bottom
                Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAvatarGrid(Color primary) {
    return Column(
      children: [
        Text('Select Avatar',
            style: TextStyle(fontSize: 16, color: Colors.black54)),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: avatarUrls.map((url) {
            final isSelected = _selectedAvatarUrl == url;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatarUrl = url),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primary : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(url),
                  child: isSelected
                      ? Icon(Icons.check_circle_rounded,
                      color: primary, size: 28)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller,
      String label, IconData icon, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildGenderPicker(Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => gender = 'Male'),
              style: OutlinedButton.styleFrom(
                backgroundColor: gender == 'Male'
                    ? primary.withOpacity(0.1)
                    : Colors.white,
                side: BorderSide(
                    color: gender == 'Male' ? primary : Colors.grey[300]!,
                    width: 1.5
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Male',
                  style: TextStyle(
                      color: gender == 'Male' ? primary : Colors.black87)),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => gender = 'Female'),
              style: OutlinedButton.styleFrom(
                backgroundColor: gender == 'Female'
                    ? primary.withOpacity(0.1)
                    : Colors.white,
                side: BorderSide(
                    color: gender == 'Female' ? primary : Colors.grey[300]!,
                    width: 1.5
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Female',
                  style: TextStyle(
                      color: gender == 'Female' ? primary : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }
}