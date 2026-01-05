import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../models/destination_model.dart';
import '../models/tour_model.dart';
import '../components/destination_card.dart'; // ✅ IMPORT ADDED
import '../screens/destination_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/booking_history_screen.dart';
import '../screens/map_screen.dart';
import '../screens/multi_city_hotel_screen.dart';
import '../screens/Car_Booking_Screen.dart';
import '../screens/Hotel_Search_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;
  int _selectedCategory = 0; // 0: Single, 1: Multi-City

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
      imageUrl: 'https://images.unsplash.com/photo-1599240636297-1eed2ae72cc3?w=800',
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
      imageUrl: 'https://images.unsplash.com/photo-1587477704623-53a0c4456e7d?w=800',
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
      imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
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
      imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
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
      imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
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
      description: 'Experience the best of Northern Areas in one amazing journey from Islamabad to all major destinations.',
      imageUrl: 'https://images.unsplash.com/photo-1599240636297-1eed2ae72cc3?w=800',
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
        {'day': 5, 'title': 'Deosai Plains', 'description': 'Visit world\'s second highest plateau'},
        {'day': 6, 'title': 'Skardu to Fairy Meadows', 'description': 'Travel to Fairy Meadows base camp'},
        {'day': 7, 'title': 'Nanga Parbat View', 'description': 'Trekking and camping at Fairy Meadows'},
        {'day': 8, 'title': 'Fairy Meadows to Naran', 'description': 'Travel to Naran Valley'},
        {'day': 9, 'title': 'Saif-ul-Mulook Lake', 'description': 'Visit famous lake and surrounding areas'},
        {'day': 10, 'title': 'Naran Exploration', 'description': 'Lulusar Lake, Babusar Top'},
        {'day': 11, 'title': 'Return Journey', 'description': 'Travel back to Islamabad'},
        {'day': 12, 'title': 'Islamabad', 'description': 'Departure or optional city tour'},
      ],
    ),
    TourPackage(
      id: 'm2',
      name: 'Hunza & Skardu Adventure',
      description: 'Perfect combination of Hunza and Skardu with all major attractions covered.',
      imageUrl: 'https://images.unsplash.com/photo-1587477704623-53a0c4456e7d?w=800',
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
        {'day': 4, 'title': 'Hunza to Skardu', 'description': 'Scenic travel between valleys'},
        {'day': 5, 'title': 'Skardu Exploration', 'description': 'Shangrila, Upper Kachura'},
        {'day': 6, 'title': 'Satpara Lake', 'description': 'Visit beautiful Satpara Lake'},
        {'day': 7, 'title': 'Return Journey', 'description': 'Travel back to Islamabad'},
        {'day': 8, 'title': 'Departure', 'description': 'End of tour'},
      ],
    ),
    TourPackage(
      id: 'm3',
      name: 'Swat & Kaghan Valley Tour',
      description: 'Explore the beautiful valleys of Swat and Kaghan in one amazing package.',
      imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
      price: 34999,
      duration: '6 Days 5 Nights',
      bestSeason: 'March to October',
      rating: 4.7,
      category: 'multi-city',
      destinations: ['Islamabad', 'Swat', 'Naran', 'Kaghan', 'Islamabad'],
      highlights: [
        'Swat Valley',
        'Kaghan Valley',
        'Malam Jabba',
        'Saif-ul-Mulook',
        'All Transportation'
      ],
      itinerary: [
        {'day': 1, 'title': 'Islamabad to Swat', 'description': 'Travel to beautiful Swat Valley'},
        {'day': 2, 'title': 'Swat Exploration', 'description': 'Malam Jabba, White Palace'},
        {'day': 3, 'title': 'Swat to Naran', 'description': 'Travel to Naran Valley'},
        {'day': 4, 'title': 'Saif-ul-Mulook', 'description': 'Visit magical lake'},
        {'day': 5, 'title': 'Kaghan Valley', 'description': 'Explore surrounding areas'},
        {'day': 6, 'title': 'Return to Islamabad', 'description': 'Travel back to capital'},
      ],
    ),
  ];

  // ✅ UPDATED SERVICES: Added City Car and All Hotels
  final List<Map<String, dynamic>> services = [
    {'icon': Icons.hotel, 'title': 'Hotels', 'color': Colors.blue, 'gradient': [Colors.blue, Colors.lightBlue]},
    {'icon': Icons.directions_car, 'title': 'Transport', 'color': Colors.green, 'gradient': [Colors.green, Colors.lightGreen]},
    {'icon': Icons.map, 'title': 'Map', 'color': Colors.orange, 'gradient': [Colors.orange, Colors.amber]},
    {'icon': Icons.directions_car, 'title': 'City Car', 'color': Colors.purple, 'gradient': [Colors.purple, Colors.pink]}, // ✅ NEW
    {'icon': Icons.hotel, 'title': 'All Hotels', 'color': Colors.teal, 'gradient': [Colors.teal, Colors.cyan]}, // ✅ NEW
    {'icon': Icons.camera_alt, 'title': 'Photos', 'color': Colors.red, 'gradient': [Colors.red, Colors.pink]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _currentIndex == 0 ? _buildHomeTab() : _buildBookingsTab(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Loading your profile...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Please login to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Traveler! 👋',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Welcome to Pakistan Tours',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final displayName = userData?['fullName'] ?? 'Traveler';

              // Time-based greetings
              final hour = DateTime.now().hour;
              String timeGreeting = 'Hello';
              String timeEmoji = '👋';

              if (hour < 12) {
                timeGreeting = 'Good Morning';
                timeEmoji = '☀️';
              } else if (hour < 17) {
                timeGreeting = 'Good Afternoon';
                timeEmoji = '🌤️';
              } else {
                timeGreeting = 'Good Evening';
                timeEmoji = '🌙';
              }

              // Personalized message
              String personalizedMessage = 'Ready for your next adventure?';
              if (displayName.length <= 4) {
                personalizedMessage = 'Adventure calls! 🗺️';
              } else if (displayName.length <= 6) {
                personalizedMessage = 'Explore amazing destinations! 🌄';
              } else {
                personalizedMessage = 'Your journey awaits! 🎒';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeGreeting, $displayName! $timeEmoji',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    personalizedMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.black87, size: 22),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: Colors.black87, size: 22),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar with beautiful design
          _buildSearchBar(),
          const SizedBox(height: 30),

          // Services Grid
          _buildServicesGrid(),
          const SizedBox(height: 30),

          // ✅ NEW: Quick Access Section
          _buildQuickAccessSection(),
          const SizedBox(height: 30),

          // Tour Type Selection
          _buildTourTypeSelector(),
          const SizedBox(height: 20),

          // Destinations or Tours based on selection
          _selectedCategory == 0
              ? _buildSingleDestinations()
              : _buildMultiCityTours(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search destinations, hotels, tours...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        onTap: () {
          // Open search screen
        },
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'What do you need?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(service);
          },
        ),
      ],
    );
  }

  // ✅ UPDATED: Service Card with new navigation
  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        if (service['title'] == 'Map') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        }
        // ✅ NEW: City to City Car Rental
        else if (service['title'] == 'City Car') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CityToCityCarBookingScreen()),
          );
        }
        // ✅ NEW: All Pakistan Hotels Booking
        else if (service['title'] == 'All Hotels') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AllPakistanHotelBookingScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: service['gradient'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: service['color'].withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(service['icon'], color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            service['title'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Quick Access Section
  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // City to City Car Rental Card
        _buildQuickAccessCard(
          icon: Icons.directions_car,
          title: 'City to City Car Rental',
          subtitle: 'Book cars for intercity travel across Pakistan',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CityToCityCarBookingScreen()),
            );
          },
        ),
        const SizedBox(height: 12),

        // All Pakistan Hotels Card
        _buildQuickAccessCard(
          icon: Icons.hotel,
          title: 'Pakistan Hotels Booking',
          subtitle: 'Find and book hotels in all major cities',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPakistanHotelBookingScreen()),
            );
          },
        ),
      ],
    );
  }

  // ✅ NEW: Quick Access Card Widget
  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTourTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Travel Style',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTourTypeCard(
                title: 'Single Destination',
                icon: Icons.location_on,
                isSelected: _selectedCategory == 0,
                onTap: () {
                  setState(() {
                    _selectedCategory = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTourTypeCard(
                title: 'Multi-City Tour',
                icon: Icons.airline_stops,
                isSelected: _selectedCategory == 1,
                onTap: () {
                  setState(() {
                    _selectedCategory = 1;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTourTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Destinations',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: singleDestinations.length,
          itemBuilder: (context, index) {
            final destination = singleDestinations[index];
            return _buildDestinationCard(destination);
          },
        ),
      ],
    );
  }

  Widget _buildMultiCityTours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Multi-City Tour Packages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: multiCityTours.length,
          itemBuilder: (context, index) {
            final tour = multiCityTours[index];
            return _buildTourPackageCard(tour);
          },
        ),
      ],
    );
  }

  // ✅ UPDATED: _buildDestinationCard using DestinationCard component
  Widget _buildDestinationCard(Destination destination) {
    return DestinationCard(
      destination: destination,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationScreen(destination: destination),
          ),
        );
      },
    );
  }

  // ✅ UPDATED: _buildTourPackageCard with CachedNetworkImage
  Widget _buildTourPackageCard(TourPackage tour) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // ✅ Navigate to Multi-City Hotel Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiCityHotelScreen(tourPackage: tour),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ UPDATED: Tour Image with CachedNetworkImage
                Container(
                  height: 160,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: tour.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tour, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tour Image', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Rating Badge
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
                                tour.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Price
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rs. ${tour.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Multi-City Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
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
                ),
                // Tour Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tour.duration,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tour.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Destinations Route
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text('Route: ${tour.destinations.join(' → ')}'),
                            backgroundColor: Colors.blue.shade50,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Highlights
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tour.highlights.take(3).map((highlight) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              highlight,
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 10,
                              ),
                            ),
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
      ),
    );
  }

  void _showTourDetails(TourPackage tour) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tour.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tour Details
                    _buildTourDetailRow('Duration', tour.duration),
                    _buildTourDetailRow('Best Season', tour.bestSeason),
                    _buildTourDetailRow('Price', 'Rs. ${tour.price.toStringAsFixed(0)}'),

                    const SizedBox(height: 20),

                    // Itinerary
                    const Text(
                      'Tour Itinerary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...tour.itinerary.map((day) => _buildItineraryDay(day)).toList(),

                    const SizedBox(height: 20),

                    // Book Now Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to booking screen
                        },
                        child: const Text('Book This Tour'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildItineraryDay(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day['day'].toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  day['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return const BookingHistoryScreen();
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      backgroundColor: Colors.white,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          activeIcon: Icon(Icons.bookmark),
          label: 'Bookings',
        ),
      ],
    );
  }
}