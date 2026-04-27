import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_auth_service.dart';
import '../services/user_listings_service.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';
import 'add_car_screen.dart';
import 'add_hotel_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Listings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: AppConstants.lightTextColor,
          indicatorColor: AppConstants.primaryColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.hotel_rounded),
              text: 'Hotels',
            ),
            Tab(
              icon: Icon(Icons.directions_car_rounded),
              text: 'Cars',
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: UserListingsService.instance,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildHotelsTab(),
              _buildCarsTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHotelsTab() {
    final email = LocalAuthService.instance.currentEmail;
    final hotels = UserListingsService.instance.hotelsByUser(email);

    return Column(
      children: [
        _buildAddButton(
          'Register New Hotel',
          Icons.add_business_rounded,
          AppConstants.primaryGradient.colors,
          () async {
            await Navigator.push(
              context,
              PageTransitions.slideUp(const AddHotelScreen()),
            );
          },
        ),
        Expanded(
          child: hotels.isEmpty
              ? _emptyState(
                  Icons.hotel_rounded,
                  'No hotels registered yet',
                  'Tap the button above to add your first hotel',
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: hotels.length,
                  itemBuilder: (context, i) {
                    return StaggeredEntry(
                      index: i,
                      child: _buildHotelCard(hotels[i]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCarsTab() {
    final email = LocalAuthService.instance.currentEmail;
    final cars = UserListingsService.instance.carsByUser(email);

    return Column(
      children: [
        _buildAddButton(
          'Register New Car',
          Icons.add_road_rounded,
          const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          () async {
            await Navigator.push(
              context,
              PageTransitions.slideUp(const AddCarScreen()),
            );
          },
        ),
        Expanded(
          child: cars.isEmpty
              ? _emptyState(
                  Icons.directions_car_rounded,
                  'No cars registered yet',
                  'Tap the button above to add your first car',
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: cars.length,
                  itemBuilder: (context, i) {
                    return StaggeredEntry(
                      index: i,
                      child: _buildCarCard(cars[i]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddButton(
    String label,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: LiquidButton(
        label: label,
        icon: icon,
        onPressed: onTap,
        colors: colors,
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingAnimation(
            offset: 6,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: AppConstants.primaryColor),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConstants.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppConstants.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(UserHotel hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppConstants.cardElevation,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: hotel.imagePath.isNotEmpty
                      ? Image.file(
                          File(hotel.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.hotel_rounded,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.hotel_rounded,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      hotel.category,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppConstants.goldAccent, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppConstants.lightTextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${hotel.city} • ${hotel.location}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppConstants.lightTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF27AE60),
                              Color(0xFF2ECC71),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Rs. ${hotel.pricePerNight.toStringAsFixed(0)}/night',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _roundAction(
                        Icons.edit_rounded,
                        AppConstants.primaryColor,
                        () async {
                          await Navigator.push(
                            context,
                            PageTransitions.slideUp(
                              AddHotelScreen(existing: hotel),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _roundAction(
                        Icons.delete_outline_rounded,
                        AppConstants.errorColor,
                        () => _confirmDeleteHotel(hotel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(UserCar car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppConstants.cardElevation,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: car.imagePath.isNotEmpty
                      ? Image.file(
                          File(car.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.directions_car_rounded,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.directions_car_rounded,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      car.type,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppConstants.goldAccent, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          car.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _carBadge(Icons.event_seat_rounded,
                          '${car.capacity} seats'),
                      _carBadge(Icons.settings_rounded, car.transmission),
                      _carBadge(
                          Icons.local_gas_station_rounded, car.fuelType),
                      if (car.ac)
                        _carBadge(Icons.ac_unit_rounded, 'AC'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF27AE60),
                              Color(0xFF2ECC71),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Rs. ${car.pricePerKm.toStringAsFixed(0)}/km',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _roundAction(
                        Icons.edit_rounded,
                        const Color(0xFF6366F1),
                        () async {
                          await Navigator.push(
                            context,
                            PageTransitions.slideUp(
                              AddCarScreen(existing: car),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _roundAction(
                        Icons.delete_outline_rounded,
                        AppConstants.errorColor,
                        () => _confirmDeleteCar(car),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppConstants.primaryColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundAction(IconData icon, Color color, VoidCallback onTap) {
    return ScaleOnTap(
      scaleDown: 0.9,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _confirmDeleteHotel(UserHotel hotel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Hotel?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${hotel.name}"? This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await UserListingsService.instance.removeHotel(hotel.id);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
                foregroundColor: AppConstants.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCar(UserCar car) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Car?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${car.name}"? This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await UserListingsService.instance.removeCar(car.id);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
                foregroundColor: AppConstants.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
