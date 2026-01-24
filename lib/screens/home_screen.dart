import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../models/destination_model.dart';
import '../models/tour_model.dart';
import '../screens/destination_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/booking_history_screen.dart';
import '../screens/map_screen.dart';
import '../screens/multi_city_hotel_screen.dart';
import '../screens/car_booking_screen.dart';
import '../screens/hotel_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();

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
      description: 'Experience the best of Northern Areas in one amazing journey.',
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
      ],
    ),
  ];

  // Services
  final List<Map<String, dynamic>> services = [
    {'icon': Icons.hotel, 'title': 'Hotels', 'color': Colors.blue, 'route': 'hotels'},
    {'icon': Icons.directions_car, 'title': 'Transport', 'color': Colors.green, 'route': 'transport'},
    {'icon': Icons.map, 'title': 'Map', 'color': Colors.orange, 'route': 'map'},
    {'icon': Icons.directions_car, 'title': 'City Car', 'color': Colors.purple, 'route': 'city_car'},
    {'icon': Icons.hotel, 'title': 'All Hotels', 'color': Colors.teal, 'route': 'all_hotels'},
    {'icon': Icons.camera_alt, 'title': 'Photos', 'color': Colors.red, 'route': 'photos'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  'Loading...',
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
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Ready for your next adventure?',
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
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildServicesGrid(),
          const SizedBox(height: 30),
          _buildQuickAccessSection(),
          const SizedBox(height: 30),
          _buildTourTypeSelector(),
          const SizedBox(height: 20),
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
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search destinations, hotels, tours...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              FocusScope.of(context).unfocus();
            },
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        switch (service['route']) {
          case 'map':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            );
            break;
          case 'city_car':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CarBookingScreen()),
            );
            break;
          case 'all_hotels':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HotelSearchScreen()),
            );
            break;
          default:
          // Handle other services
            break;
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
                colors: [service['color'], service['color'].withOpacity(0.7)],
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
        Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CarBookingScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'City to City Car Rental',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Book cars for intercity travel across Pakistan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // All Pakistan Hotels Card
        Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HotelSearchScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hotel, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pakistan Hotels Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find and book hotels in all major cities',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.purple, size: 16),
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
          children: tourCategories.map((category) {
            final index = tourCategories.indexOf(category);
            final isSelected = _selectedCategory == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
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
                        category['icon'],
                        color: isSelected ? Colors.blue : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['title'],
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
              ),
            );
          }).toList(),
        ),
      ],
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

  Widget _buildDestinationCard(Destination destination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationScreen(destination: destination),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
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
                  child: CachedNetworkImage(
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        destination.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        destination.duration,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
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
    );
  }

  Widget _buildTourPackageCard(TourPackage tour) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiCityHotelScreen(tourPackage: tour),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
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
                  child: CachedNetworkImage(
                    imageUrl: tour.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
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
                      Text(
                        tour.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tour.duration,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tour.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
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