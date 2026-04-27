import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/auth_service.dart';
import '../models/destination_model.dart';
import '../models/tour_model.dart';
import '../screens/destination_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/booking_history_screen.dart';
import '../screens/map_screen.dart';
import '../screens/multi_city_hotel_screen.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';
import 'add_car_screen.dart';
import 'add_hotel_screen.dart';
import 'car_booking_screen.dart';
import 'hotel_search_screen.dart';
import 'my_listings_screen.dart';
import 'weather_screen.dart';
import 'chat_screen.dart';
import 'review_screen.dart';
import 'admin_dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  late int _currentIndex = widget.initialTab;
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchFocused = false;

  // Animation controllers
  late AnimationController _servicesAnimController;
  late AnimationController _cardsAnimController;

  // Categories for tour selection
  final List<Map<String, dynamic>> tourCategories = [
    {'title': 'Single Destination', 'icon': Icons.location_on, 'type': 'single'},
    {'title': 'Multi-City Tour', 'icon': Icons.airline_stops, 'type': 'multi'},
  ];

  // Single Destinations
  final List<Destination> singleDestinations = [
    Destination(
      id: '1',
      name: 'Hunza Valley',
      description: 'Heaven on Earth with stunning views of Rakaposhi and Ultar Sar peaks.',
      imageUrl: 'assets/images/destinations/Hunza_1.jpg',
      rating: 4.9,
      location: 'Gilgit-Baltistan, Pakistan',
      price: 24999,
      duration: '5 Days 4 Nights',
      bestSeason: 'April to October',
      highlights: ['Baltit Fort', 'Attabad Lake', 'Passu Cones', 'Khunjerab Pass'],
    ),
    Destination(
      id: '2',
      name: 'Skardu & Shangrila',
      description: 'Gateway to the world\'s highest peaks including K2.',
      imageUrl: 'assets/images/destinations/Skardu_&_Shangrila_1.jpg',
      rating: 4.8,
      location: 'Skardu, Gilgit-Baltistan',
      price: 29999,
      duration: '7 Days 6 Nights',
      bestSeason: 'May to September',
      highlights: ['Shangrila Resort', 'Upper Kachura Lake', 'K2 Base Camp'],
    ),
    Destination(
      id: '3',
      name: 'Swat Valley',
      description: 'Switzerland of Pakistan with green valleys, waterfalls, and ancient Buddhist heritage sites.',
      imageUrl: 'assets/images/destinations/Swat_Valley_1.jpg',
      rating: 4.7,
      location: 'Khyber Pakhtunkhwa, Pakistan',
      price: 18999,
      duration: '4 Days 3 Nights',
      bestSeason: 'March to October',
      highlights: ['Malam Jabba', 'Mahodand Lake', 'White Palace', 'Waterfalls'],
    ),
    Destination(
      id: '4',
      name: 'Naran & Kaghan',
      description: 'Beautiful valleys with lakes, pine forests, and stunning mountain views.',
      imageUrl: 'assets/images/destinations/Naran_&_Kaghan_1.jpeg',
      rating: 4.6,
      location: 'Khyber Pakhtunkhwa, Pakistan',
      price: 17999,
      duration: '4 Days 3 Nights',
      bestSeason: 'May to September',
      highlights: ['Saif-ul-Mulook', 'Lulusar Lake', 'Babusar Top', 'Pine Forests'],
    ),
    Destination(
      id: '5',
      name: 'Fairy Meadows',
      description: 'Magical grassland at the base of Nanga Parbat, the killer mountain.',
      imageUrl: 'assets/images/destinations/Fairy_Meadows_1.jpg',
      rating: 4.8,
      location: 'Diamer, Gilgit-Baltistan',
      price: 21999,
      duration: '3 Days 2 Nights',
      bestSeason: 'June to September',
      highlights: ['Nanga Parbat View', 'Beyal Camp', 'Jhelum Meadows', 'Trekking'],
    ),
  ];

  // Multi-City Tour Packages
  final List<TourPackage> multiCityTours = [
    TourPackage(
      id: 'm1',
      name: 'Complete Northern Pakistan Tour',
      description: 'Experience the best of Northern Areas in one amazing journey.',
      imageUrl: 'assets/images/destinations/Hunza_1.jpg',
      price: 69999,
      duration: '12 Days 11 Nights',
      bestSeason: 'May to September',
      rating: 4.9,
      category: 'multi-city',
      destinations: ['Islamabad', 'Hunza', 'Skardu', 'Fairy Meadows', 'Naran', 'Islamabad'],
      highlights: [
        'All Major Northern Destinations',
        'Comfortable Transport',
        'Best Hotels',
        'Professional Guide',
        'All Meals Included'
      ],
      itinerary: [
        {'day': 1, 'title': 'Islamabad to Hunza', 'description': 'Travel from Islamabad to Hunza Valley'},
        {'day': 2, 'title': 'Hunza Exploration', 'description': 'Visit Baltit Fort, Attabad Lake'},
        {'day': 3, 'title': 'Hunza to Skardu', 'description': 'Travel to Skardu via beautiful routes'},
        {'day': 4, 'title': 'Skardu Sightseeing', 'description': 'Shangrila Resort, Upper Kachura Lake'},
      ],
    ),
    TourPackage(
      id: 'm2',
      name: 'Hunza & Skardu Adventure',
      description: 'Perfect combination of Hunza and Skardu with all major attractions covered.',
      imageUrl: 'assets/images/destinations/Skardu_&_Shangrila_1.jpg',
      price: 49999,
      duration: '8 Days 7 Nights',
      bestSeason: 'April to October',
      rating: 4.8,
      category: 'multi-city',
      destinations: ['Islamabad', 'Hunza', 'Skardu', 'Islamabad'],
      highlights: [
        'Hunza Valley Exploration',
        'Skardu Lakes',
        'Comfortable Journey',
        'All Entry Fees Included'
      ],
      itinerary: [
        {'day': 1, 'title': 'Islamabad to Hunza', 'description': 'Travel from capital to Hunza'},
        {'day': 2, 'title': 'Hunza Sightseeing', 'description': 'Baltit Fort, Altit Fort'},
        {'day': 3, 'title': 'Attabad Lake', 'description': 'Boat ride and photography'},
      ],
    ),
  ];

  // Services
  final List<Map<String, dynamic>> services = [
    {'icon': Icons.hotel, 'title': 'Hotels', 'color': Colors.blue, 'route': 'hotels'},
    {'icon': Icons.directions_car, 'title': 'Transport', 'color': Colors.green, 'route': 'transport'},
    {'icon': Icons.map, 'title': 'Map', 'color': Colors.orange, 'route': 'map'},
    {'icon': Icons.wb_sunny_rounded, 'title': 'Weather', 'color': const Color(0xFF11998E), 'route': 'weather'},
    {'icon': Icons.chat_bubble_rounded, 'title': 'Chat', 'color': const Color(0xFF667EEA), 'route': 'chat'},
    {'icon': Icons.star_rounded, 'title': 'Reviews', 'color': Colors.amber, 'route': 'reviews'},
    {'icon': Icons.admin_panel_settings, 'title': 'Admin', 'color': const Color(0xFF764BA2), 'route': 'admin'},
    {'icon': Icons.camera_alt, 'title': 'Photos', 'color': Colors.red, 'route': 'photos'},
  ];

  final List<Map<String, String>> _allPhotos = [
    {'image': 'assets/images/destinations/Hunza_1.jpg', 'title': 'Hunza Valley'},
    {'image': 'assets/images/destinations/Skardu_&_Shangrila_1.jpg', 'title': 'Skardu & Shangrila'},
    {'image': 'assets/images/destinations/Swat_Valley_1.jpg', 'title': 'Swat Valley'},
    {'image': 'assets/images/destinations/Naran_&_Kaghan_1.jpeg', 'title': 'Naran & Kaghan'},
    {'image': 'assets/images/destinations/Fairy_Meadows_1.jpg', 'title': 'Fairy Meadows'},
  ];

  void _showPhotoGallery() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pakistan Photo Gallery',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _allPhotos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      final destination = singleDestinations.firstWhere(
                        (d) => d.name == _allPhotos[index]['title'],
                        orElse: () => singleDestinations[0],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationScreen(destination: destination),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            _allPhotos[index]['image']!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black87, Colors.transparent],
                                ),
                              ),
                              child: Text(
                                _allPhotos[index]['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _servicesAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _searchFocusNode.addListener(() {
      setState(() => _searchFocused = _searchFocusNode.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _servicesAnimController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _cardsAnimController.forward();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _servicesAnimController.dispose();
    _cardsAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _currentIndex == 0
            ? Container(key: const ValueKey('home'), child: _buildHomeTab())
            : Container(key: const ValueKey('bookings'), child: _buildBookingsTab()),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D47A1),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: null,
      title: StreamBuilder<User?>(
        stream: _authService.userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Traveler! 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            );
          }

          final user = userSnapshot.data;
          if (user == null) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Guest! 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Please login to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            );
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello! 👋',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                );
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final displayName = userData?['fullName'] ?? user.displayName ?? 'Traveler';

              final hour = DateTime.now().hour;
              String timeGreeting = 'Good Evening';
              String timeEmoji = '🌙';

              if (hour < 12) {
                timeGreeting = 'Good Morning';
                timeEmoji = '☀️';
              } else if (hour < 17) {
                timeGreeting = 'Good Afternoon';
                timeEmoji = '🌤️';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeGreeting, $displayName! $timeEmoji',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Ready for your next adventure?',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageTransitions.fadeSlide(const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(),
                const SizedBox(height: 8),
                _buildServicesGrid(),
                const SizedBox(height: 32),
                _buildSpecialOfferBanner(),
                const SizedBox(height: 28),
                _buildPartnerBanner(),
                const SizedBox(height: 28),
                _buildQuickAccessSection(),
                const SizedBox(height: 32),
                _buildTourTypeSelector(),
                const SizedBox(height: 20),
                _selectedCategory == 0
                    ? _buildSingleDestinations()
                    : _buildMultiCityTours(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 50),
      beginOffset: const Offset(0, -0.1),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 40,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Discover Pakistan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ShimmerText(
              text: 'Where will you',
              highlightColor: const Color(0xFFFFD54F),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            GradientText(
              text: 'go next?',
              colors: const [Color(0xFFFFD54F), Color(0xFFFFAB40), Color(0xFFFFFFFF)],
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            TypewriterText(
              text: 'Explore breathtaking destinations across Pakistan',
              duration: const Duration(milliseconds: 2200),
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOfferBanner() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 220),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3949AB).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_offer, color: Colors.black87, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'SPECIAL OFFER',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Summer Sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get 25% off on all tours\nLimited time offer',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PulseAnimation(
                  minScale: 0.98,
                  maxScale: 1.08,
                  child: GlowPulse(
                    glowColor: const Color(0xFFFFC107),
                    maxRadius: 30,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFA726)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '25%',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'OFF',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerBanner() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 240),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364), Color(0xFF00BFA5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppConstants.accentColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: FloatingAnimation(
                offset: 8,
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
              right: 40,
              bottom: -40,
              child: FloatingAnimation(
                offset: 10,
                duration: const Duration(seconds: 4),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: Colors.black87, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'BECOME A PARTNER',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ShimmerText(
                  text: 'List Your Hotel or Car',
                  highlightColor: const Color(0xFFFFD54F),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Earn money by renting out your property\nor vehicle to travelers — it\'s easy!',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ScaleOnTap(
                        scaleDown: 0.96,
                        onTap: () => Navigator.push(
                          context,
                          PageTransitions.slideUp(const AddHotelScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFAB40), Color(0xFFFF7043)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.warmAccent
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.hotel_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Add Hotel',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ScaleOnTap(
                        scaleDown: 0.96,
                        onTap: () => Navigator.push(
                          context,
                          PageTransitions.slideUp(const AddCarScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1)
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_car_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Add Car',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: ScaleOnTap(
                    onTap: () => Navigator.push(
                      context,
                      PageTransitions.slideUp(const MyListingsScreen()),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list_alt_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'View My Listings',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 150),
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatItem(5, '+', 'Destinations', Icons.location_on_rounded, AppConstants.primaryColor),
              _buildStatDivider(),
              _buildStatItem(20, '+', 'Hotels', Icons.hotel_rounded, AppConstants.accentColor),
              _buildStatDivider(),
              _buildStatItem(9, '', 'Tourist Spots', Icons.explore_rounded, AppConstants.warmAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(int value, String suffix, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          FloatingAnimation(
            offset: 3,
            duration: const Duration(seconds: 3),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedCounter(
            value: value,
            suffix: suffix,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppConstants.textColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppConstants.lightTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppConstants.borderColor,
    );
  }

  Widget _buildSearchBar() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _searchFocused ? AppConstants.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _searchFocused
                  ? AppConstants.primaryColor.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: _searchFocused ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search destinations, hotels, tours...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _searchFocused ? AppConstants.primaryColor : Colors.grey[500],
              size: 24,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'What do you need?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.8,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final start = (index * 0.1).clamp(0.0, 0.6);
            final end = (start + 0.5).clamp(0.0, 1.0);
            final animation = CurvedAnimation(
              parent: _servicesAnimController,
              curve: Interval(start, end, curve: Curves.easeOutBack),
            );
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Opacity(
                  opacity: animation.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.5 + (0.5 * animation.value.clamp(0.0, 1.0)),
                    child: child,
                  ),
                );
              },
              child: _buildServiceCard(service),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return ScaleOnTap(
      scaleDown: 0.88,
      onTap: () {
        switch (service['route']) {
          case 'hotels':
            Navigator.push(context, PageTransitions.fadeSlide(AllPakistanHotelBookingScreen()));
            break;
          case 'transport':
            Navigator.push(context, PageTransitions.fadeSlide(CityToCityCarBookingScreen()));
            break;
          case 'map':
            Navigator.push(context, PageTransitions.fadeSlide(MapScreen()));
            break;
          case 'weather':
            Navigator.push(context, PageTransitions.fadeSlide(const WeatherScreen()));
            break;
          case 'chat':
            Navigator.push(context, PageTransitions.fadeSlide(const ChatScreen()));
            break;
          case 'reviews':
            Navigator.push(context, PageTransitions.fadeSlide(const ReviewScreen()));
            break;
          case 'admin':
            Navigator.push(context, PageTransitions.fadeSlide(const AdminDashboardScreen()));
            break;
          case 'photos':
            _showPhotoGallery();
            break;
          default:
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingAnimation(
            offset: 4,
            duration: const Duration(milliseconds: 2600),
            child: GlowPulse(
              glowColor: service['color'],
              maxRadius: 24,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [service['color'], service['color'].withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: service['color'].withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(service['icon'], color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            service['title'],
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppConstants.textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 250),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppConstants.accentGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // City to City Car Rental Card
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 300),
          beginOffset: const Offset(-0.2, 0),
          child: ScaleOnTap(
            scaleDown: 0.97,
            onTap: () => Navigator.push(
              context,
              PageTransitions.fadeSlide(CityToCityCarBookingScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'City to City Car Rental',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Book cars for intercity travel',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // All Pakistan Hotels Card
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 400),
          beginOffset: const Offset(-0.2, 0),
          child: ScaleOnTap(
            scaleDown: 0.97,
            onTap: () => Navigator.push(
              context,
              PageTransitions.fadeSlide(AllPakistanHotelBookingScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7043), Color(0xFFFF9F40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7043).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pakistan Hotels Booking',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find hotels in all major cities',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTourTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 350),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Choose Your Travel Style',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 450),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: tourCategories.map((category) {
                final index = tourCategories.indexOf(category);
                final isSelected = _selectedCategory == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppConstants.primaryGradient : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppConstants.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: isSelected ? 1.1 : 1.0,
                            child: Icon(
                              category['icon'],
                              color: isSelected ? Colors.white : Colors.grey[500],
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.grey[600]!,
                            ),
                            child: Text(category['title']),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCarousel() {
    return CarouselSlider.builder(
      itemCount: singleDestinations.length,
      itemBuilder: (context, index, realIndex) {
        final destination = singleDestinations[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageTransitions.heroFade(DestinationScreen(destination: destination)),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    left: 18,
                    right: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                destination.location,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 230,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 900),
        autoPlayCurve: Curves.easeInOutCubic,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        viewportFraction: 0.82,
      ),
    );
  }

  Widget _buildSingleDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 300),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppConstants.warmGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Featured Destinations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 400),
          child: _buildFeaturedCarousel(),
        ),
        const SizedBox(height: 24),
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 500),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Destinations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: singleDestinations.length,
          itemBuilder: (context, index) {
            final destination = singleDestinations[index];
            return StaggeredListItem(
              index: index,
              animation: _cardsAnimController,
              child: _buildDestinationCard(destination),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMultiCityTours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedFadeSlide(
          delay: const Duration(milliseconds: 300),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppConstants.accentGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Multi-City Tour Packages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: multiCityTours.length,
          itemBuilder: (context, index) {
            final tour = multiCityTours[index];
            return StaggeredListItem(
              index: index,
              animation: _cardsAnimController,
              child: _buildTourPackageCard(tour),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageTransitions.heroFade(DestinationScreen(destination: destination)),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'destination_${destination.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: destination.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              destination.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: destination.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                    ),
                  ),
                  // POPULAR / TRENDING Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: destination.rating >= 4.8
                            ? const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF9F40)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            destination.rating >= 4.8 ? Icons.local_fire_department : Icons.trending_up,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating >= 4.8 ? 'POPULAR' : 'TRENDING',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: AppConstants.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.accentColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Rs. ${destination.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          destination.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        destination.duration,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: destination.highlights.take(3).map((highlight) {
                      return Chip(
                        label: Text(highlight),
                        backgroundColor: Colors.blue[50],
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
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

  Widget _buildTourPackageCard(TourPackage tour) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageTransitions.fadeSlide(MultiCityHotelScreen(tourPackage: tour)),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: tour.imageUrl.startsWith('assets/')
                      ? Image.asset(
                          tour.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(Icons.tour, size: 50, color: Colors.grey),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: tour.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(Icons.tour, size: 50, color: Colors.grey),
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.airline_stops, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Multi-City',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tour.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppConstants.accentGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.accentColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Rs. ${tour.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tour.duration,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tour.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tour.destinations.map((city) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            city,
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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

  Widget _buildBookingsTab() {
    return const BookingHistoryScreen();
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.bookmark_rounded,
                  label: 'Bookings',
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppConstants.primaryGradient : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[500],
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}