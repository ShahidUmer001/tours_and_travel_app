import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ ADDED: Firebase Storage
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Settings variables
  String _language = 'English';
  String _nightMode = 'System';
  File? _profileImageFile;
  bool _isLoading = false;
  bool _isImageUploading = false; // ✅ ADDED: Image upload loading state

  // Available languages
  final List<String> _languages = [
    'English',
    'اردو',
    'عربي',
    'Spanish',
    'French'
  ];

  // Available night modes
  final List<String> _nightModes = [
    'System',
    'On',
    'Off'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ===================== AUTH METHODS =====================
  void _logout() async {
    await _authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  // ===================== UPDATED IMAGE PICKER WITH FIREBASE UPLOAD =====================
  Future<void> _pickProfileImage() async {
    try {
      // First check and request permission
      PermissionStatus status = await Permission.photos.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        // Request permission
        status = await Permission.photos.request();

        if (status.isDenied || status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied to access photos'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Now pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _isImageUploading = true; // Start loading
        });

        // ✅ UPLOAD TO FIREBASE STORAGE
        await _uploadImageToFirebase(File(pickedFile.path));

        setState(() {
          _profileImageFile = File(pickedFile.path);
          _isImageUploading = false; // Stop loading
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _isImageUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===================== NEW: FIREBASE STORAGE UPLOAD FUNCTION =====================
  Future<void> _uploadImageToFirebase(File imageFile) async {
    try {
      final User? user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() => {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with image URL
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
      });

      print('Image uploaded to: $downloadUrl');
    } catch (e) {
      print('Firebase upload error: $e');
      throw e;
    }
  }

  // ===================== SETTINGS METHODS =====================
  Future<void> _loadSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String language = prefs.getString('language') ?? 'English';
      final String nightMode = prefs.getString('nightMode') ?? 'System';

      setState(() {
        _language = language;
        _nightMode = nightMode;
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _language);
      await prefs.setString('nightMode', _nightMode);

      final User? user = _authService.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'settings': {
            'language': _language,
            'nightMode': _nightMode,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ===================== PROFILE EDIT METHODS =====================
  void _showEditProfileDialog(Map<String, dynamic> userData) {
    TextEditingController fullNameController = TextEditingController(text: userData['fullName'] ?? '');
    TextEditingController phoneController = TextEditingController(text: userData['phone'] ?? '');
    TextEditingController addressController = TextEditingController(text: userData['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateProfile(
                fullNameController.text,
                phoneController.text,
                addressController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String fullName, String phone, String address) async {
    final User? user = _authService.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fullName': fullName,
          'phone': phone,
          'address': address,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===================== SETTINGS DIALOGS =====================
  void _showPhoneNumberDialog() {
    final User? user = _authService.currentUser;
    String currentPhone = '+92********53';

    TextEditingController phoneController = TextEditingController(
      text: currentPhone.replaceAll('*', ''),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+92XXXXXXXXXX',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          maxLength: 13,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.length >= 12) {
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).update({
                    'phone': phoneController.text,
                  });
                }
                Navigator.pop(context);
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid phone number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(_languages[index]),
                value: _languages[index],
                groupValue: _language,
                onChanged: (value) {
                  setState(() {
                    _language = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showNightModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Night Mode'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView.builder(
            itemCount: _nightModes.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(_nightModes[index]),
                value: _nightModes[index],
                groupValue: _nightMode,
                onChanged: (value) {
                  setState(() {
                    _nightMode = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRulesAndTerms() async {
    const url = 'https://yourwebsite.com/terms';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open terms and conditions'),
        ),
      );
    }
  }

  // ===================== ACCOUNT DELETE =====================
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
              'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final User? user = _authService.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        await _authService.signOut();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===================== BOOKING HISTORY =====================
  void _showBookingHistory(String? userId) {
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking History'),
        content: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('bookings')
              .where('userId', isEqualTo: userId)
              .orderBy('bookingDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No bookings found.');
            }

            return SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var booking = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.hotel, color: Colors.blue),
                      title: Text(booking['hotelName'] ?? 'Unknown Hotel'),
                      subtitle: Text('Rs. ${booking['totalPrice'] ?? '0'}'),
                      trailing: Text(
                        _formatDate(booking['bookingDate']),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ===================== OTHER DIALOGS =====================
  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🔐 Your data is secure with us.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('• We never share your personal information'),
            Text('• All payments are encrypted'),
            Text('• You can delete your account anytime'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 Contact Us',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Phone: +92-3105959607'),
            Text('Email: support@tours&travelapp.com'),
            Text('Hours: 9AM - 6PM (Mon-Sat)'),
            SizedBox(height: 10),
            Text('Need immediate help? Call us anytime!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏔️ Pakistan Travel Guide',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Text('Version: 1.0.0'),
            Text('Build: 2024.01.01'),
            SizedBox(height: 10),
            Text('Discover the beauty of Pakistan with our travel app. Book hotels, plan trips, and explore amazing destinations.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ===================== HELPER METHODS =====================
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }

  String _getMaskedPhoneNumber() {
    return '+92********53';
  }

  // ===================== UPDATED PROFILE HEADER WITH LOADING =====================
  Widget _buildProfileHeader(Map<String, dynamic>? userData, User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              // Loading indicator while uploading
              if (_isImageUploading)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade700,
                  backgroundImage: _profileImageFile != null
                      ? FileImage(_profileImageFile!)
                      : userData?['profileImageUrl'] != null
                      ? NetworkImage(userData!['profileImageUrl'])
                      : null,
                  child: _profileImageFile == null &&
                      (userData?['profileImageUrl'] == null ||
                          (userData?['profileImageUrl'] as String).isEmpty)
                      ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  )
                      : null,
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isImageUploading ? null : _pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isImageUploading ? Colors.grey : Colors.blue.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: _isImageUploading ? Colors.grey.shade400 : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userData?['fullName'] ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (userData?['phone'] != null && userData!['phone'].isNotEmpty)
            Text(
              userData['phone'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),

        // Phone Number Setting
        _buildSettingItem(
          icon: Icons.phone,
          title: 'Phone number',
          value: _getMaskedPhoneNumber(),
          onTap: _showPhoneNumberDialog,
        ),

        // Language Setting
        _buildSettingItem(
          icon: Icons.language,
          title: 'Language',
          value: _language,
          onTap: _showLanguageDialog,
        ),

        // Night Mode Setting
        _buildSettingItem(
          icon: _nightMode == 'On'
              ? Icons.nightlight_round
              : Icons.light_mode,
          title: 'Night mode',
          value: _nightMode,
          onTap: _showNightModeDialog,
        ),

        // Navigation Setting
        _buildSettingItem(
          icon: Icons.navigation,
          title: 'Navigation',
          value: 'Settings',
          onTap: () {
            // Optional: NavigationSettingsScreen add karein
          },
        ),

        // Rules and Terms
        _buildSettingItem(
          icon: Icons.description,
          title: 'Rules and terms',
          value: '',
          onTap: _showRulesAndTerms,
        ),

        // Save Settings Button
        const SizedBox(height: 20),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: value.isNotEmpty ? Text(value) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // ===================== MAIN BUILD METHOD =====================
  @override
  Widget build(BuildContext context) {
    final User? user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null ? _firestore.collection('users').doc(user.uid).snapshots() : null,
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(userData, user),

                const SizedBox(height: 30),

                // Profile Options
                _buildProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    _showEditProfileDialog(userData ?? {});
                  },
                ),
                _buildProfileOption(
                  icon: Icons.history,
                  title: 'Booking History',
                  onTap: () {
                    _showBookingHistory(user?.uid);
                  },
                ),
                _buildProfileOption(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  onTap: _showPrivacySettings,
                ),
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: _showHelpSupport,
                ),
                _buildProfileOption(
                  icon: Icons.info,
                  title: 'About App',
                  onTap: _showAboutApp,
                ),

                const SizedBox(height: 30),

                // Settings Section
                _buildSettingsSection(),

                // Logout and Delete Account Buttons
                const SizedBox(height: 20),
                Column(
                  children: [
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Delete Account Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: _showDeleteAccountDialog,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                        ),
                        child: const Text(
                          'Delete Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}