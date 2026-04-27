import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/local_auth_service.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';
import 'add_car_screen.dart';
import 'add_hotel_screen.dart';
import 'login_screen.dart';
import 'my_listings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Settings variables
  String _language = 'English';
  String _nightMode = 'System';
  File? _profileImageFile;
  bool _isLoading = false;
  bool _isImageUploading = false;

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
    await LocalAuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
          if (!mounted) return;
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
          _isImageUploading = true;
        });

        // UPLOAD TO FIREBASE STORAGE
        await _uploadImageToFirebase(File(pickedFile.path));

        setState(() {
          _profileImageFile = File(pickedFile.path);
          _isImageUploading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() {
        _isImageUploading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===================== FIREBASE STORAGE UPLOAD FUNCTION =====================
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

      debugPrint('Image uploaded to: $downloadUrl');
    } catch (e) {
      debugPrint('Firebase upload error: $e');
      rethrow;
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
      debugPrint('Error loading settings: $e');
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              if (mounted) Navigator.pop(context);
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

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
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
                if (mounted) Navigator.pop(context);
                if (mounted) setState(() {});
              } else {
                if (!mounted) return;
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _language = value;
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNightModeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _nightMode = value;
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRulesAndTerms() async {
    const url = 'https://yourwebsite.com/terms';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (!mounted) return;
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

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
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

  // ===================== FIXED PROFILE HEADER =====================
  Widget _buildProfileHeader(Map<String, dynamic>? userData, User? user) {
    ImageProvider<Object>? backgroundImage;

    if (_profileImageFile != null) {
      backgroundImage = FileImage(_profileImageFile!);
    } else if (userData?['profileImageUrl'] != null &&
        userData!['profileImageUrl'] is String &&
        (userData['profileImageUrl'] as String).isNotEmpty) {
      backgroundImage = NetworkImage(userData['profileImageUrl'] as String);
    }

    return AnimatedFadeSlide(
      beginOffset: const Offset(0, -0.15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        decoration: BoxDecoration(
          gradient: AppConstants.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative floating blobs
            Positioned(
              top: -30,
              right: -20,
              child: FloatingAnimation(
                offset: 10,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: FloatingAnimation(
                offset: 12,
                duration: const Duration(seconds: 4),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                FloatingAnimation(
                  offset: 5,
                  child: GlowPulse(
                    glowColor: AppConstants.goldAccent,
                    maxRadius: 44,
                    borderRadius: BorderRadius.circular(999),
                    child: Stack(
                      children: [
                        if (_isImageUploading)
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD54F), Color(0xFFFF7043)],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white,
                              backgroundImage: backgroundImage,
                              child: backgroundImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 52,
                                      color: AppConstants.primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: ScaleOnTap(
                            onTap: _isImageUploading ? null : _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isImageUploading
                                    ? Colors.grey
                                    : AppConstants.warmAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ShimmerText(
                  text: userData?['fullName'] ?? 'User',
                  highlightColor: const Color(0xFFFFD54F),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email_outlined,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        user?.email ?? 'No email',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (userData?['phone'] != null &&
                    (userData!['phone'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    userData['phone'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Animated stat badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileStat(12, 'Trips', Icons.flight_takeoff_rounded),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    _buildProfileStat(8, 'Reviews', Icons.star_rounded),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    _buildProfileStat(5, 'Saved', Icons.bookmark_rounded),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(int value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        AnimatedCounter(
          value: value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredEntry(
          index: 0,
          child: _buildSettingItem(
            icon: Icons.phone,
            title: 'Phone number',
            value: _getMaskedPhoneNumber(),
            onTap: _showPhoneNumberDialog,
          ),
        ),
        StaggeredEntry(
          index: 1,
          child: _buildSettingItem(
            icon: Icons.language,
            title: 'Language',
            value: _language,
            onTap: _showLanguageDialog,
          ),
        ),
        StaggeredEntry(
          index: 2,
          child: _buildSettingItem(
            icon: _nightMode == 'On'
                ? Icons.nightlight_round
                : Icons.light_mode,
            title: 'Night mode',
            value: _nightMode,
            onTap: _showNightModeDialog,
          ),
        ),
        StaggeredEntry(
          index: 3,
          child: _buildSettingItem(
            icon: Icons.description,
            title: 'Rules and terms',
            value: '',
            onTap: _showRulesAndTerms,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 400),
          child: LiquidButton(
            label: _isLoading ? 'SAVING...' : 'SAVE SETTINGS',
            icon: Icons.save_rounded,
            isLoading: _isLoading,
            onPressed: _saveSettings,
            colors: const [
              AppConstants.successColor,
              Color(0xFF16A085),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ScaleOnTap(
      scaleDown: 0.97,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppConstants.cardElevation,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.primaryLight, AppConstants.primaryColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppConstants.textColor,
                    ),
                  ),
                  if (value.isNotEmpty)
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppConstants.lightTextColor,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppConstants.lightTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppConstants.primaryColor;
    return ScaleOnTap(
      scaleDown: 0.97,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppConstants.cardElevation,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppConstants.textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios, size: 12, color: c),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== MAIN BUILD METHOD =====================
  @override
  Widget build(BuildContext context) {
    final User? user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppConstants.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null ? _firestore.collection('users').doc(user.uid).snapshots() : null,
        builder: (context, snapshot) {
          final Map<String, dynamic>? userData = snapshot.data?.data() != null
              ? snapshot.data!.data() as Map<String, dynamic>
              : null;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(userData, user),
                const SizedBox(height: 24),

                _buildPartnerSection(),
                const SizedBox(height: 22),

                _buildSectionHeader(
                  'Account',
                  Icons.person_rounded,
                  AppConstants.primaryColor,
                ),
                const SizedBox(height: 10),
                StaggeredEntry(
                  index: 0,
                  child: _buildProfileOption(
                    icon: Icons.edit_rounded,
                    title: 'Edit Profile',
                    color: AppConstants.primaryColor,
                    onTap: () => _showEditProfileDialog(userData ?? {}),
                  ),
                ),
                StaggeredEntry(
                  index: 1,
                  child: _buildProfileOption(
                    icon: Icons.history_rounded,
                    title: 'Booking History',
                    color: AppConstants.accentColor,
                    onTap: () => _showBookingHistory(user?.uid),
                  ),
                ),
                StaggeredEntry(
                  index: 2,
                  child: _buildProfileOption(
                    icon: Icons.security_rounded,
                    title: 'Privacy & Security',
                    color: AppConstants.successColor,
                    onTap: _showPrivacySettings,
                  ),
                ),
                StaggeredEntry(
                  index: 3,
                  child: _buildProfileOption(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    color: AppConstants.warmAccent,
                    onTap: _showHelpSupport,
                  ),
                ),
                StaggeredEntry(
                  index: 4,
                  child: _buildProfileOption(
                    icon: Icons.info_outline_rounded,
                    title: 'About App',
                    color: AppConstants.infoColor,
                    onTap: _showAboutApp,
                  ),
                ),

                const SizedBox(height: 22),
                _buildSectionHeader(
                  'Settings',
                  Icons.settings_rounded,
                  AppConstants.accentColor,
                ),
                const SizedBox(height: 10),
                _buildSettingsSection(),

                const SizedBox(height: 14),
                AnimatedFadeSlide(
                  delay: const Duration(milliseconds: 500),
                  child: ScaleOnTap(
                    scaleDown: 0.96,
                    onTap: _logout,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppConstants.errorColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: AppConstants.cardElevation,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: AppConstants.errorColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppConstants.errorColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                AnimatedFadeSlide(
                  delay: const Duration(milliseconds: 600),
                  child: TextButton.icon(
                    onPressed: _showDeleteAccountDialog,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppConstants.errorColor),
                    label: Text(
                      'Delete Account',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartnerSection() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3949AB).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FloatingAnimation(
                  offset: 4,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.business_center_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(
                        text: 'Become a Partner',
                        highlightColor: const Color(0xFFFFD54F),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Register your hotel or car and earn',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _partnerAction(
                    Icons.hotel_rounded,
                    'Add Hotel',
                    const [Color(0xFFFFAB40), Color(0xFFFF7043)],
                    () {
                      Navigator.push(
                        context,
                        PageTransitions.slideUp(const AddHotelScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _partnerAction(
                    Icons.directions_car_rounded,
                    'Add Car',
                    const [Color(0xFF00BFA5), Color(0xFF00E5FF)],
                    () {
                      Navigator.push(
                        context,
                        PageTransitions.slideUp(const AddCarScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _partnerAction(
                    Icons.list_alt_rounded,
                    'My Listings',
                    const [Color(0xFFFFD54F), Color(0xFFFFC107)],
                    () {
                      Navigator.push(
                        context,
                        PageTransitions.slideUp(const MyListingsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _partnerAction(
    IconData icon,
    String label,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return ScaleOnTap(
      scaleDown: 0.94,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 200),
      beginOffset: const Offset(-0.1, 0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.textColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}