// screens/booking_history_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import '../models/car_booking_model.dart';
import '../models/hotel_booking_model.dart';
import '../services/auth_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();
  int _selectedTab = 0; // 0: All, 1: Tours, 2: Hotels, 3: Cars

  // Simple date formatter function (no intl package needed)
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateWithMonth(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),

          Expanded(
            child: StreamBuilder<User?>(
              stream: _authService.userStream,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                final user = userSnapshot.data;
                if (user == null) {
                  return _buildGuestState();
                }

                return _buildBookingsContent(user.uid);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('All', 0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton('Tours', 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton('Hotels', 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton('Cars', 3),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTab = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildBookingsContent(String userId) {
    switch (_selectedTab) {
      case 0: // All
        return _buildAllBookings(userId);
      case 1: // Tours
        return _buildTourBookings(userId);
      case 2: // Hotels
        return _buildHotelBookings(userId);
      case 3: // Cars
        return _buildCarBookings(userId);
      default:
        return _buildAllBookings(userId);
    }
  }

  Widget _buildAllBookings(String userId) {
    final List<dynamic> allBookings = [
      // Sample tour bookings
      Booking(
        id: '1',
        userId: userId,
        destinationName: 'Hunza Valley',
        destinationId: '1',
        totalPrice: 25000,
        guests: 2,
        status: 'confirmed',
        bookingDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      // Sample hotel booking
      HotelBooking(
        id: 'h1',
        userId: userId,
        hotelId: 'hotel1',
        hotelName: 'Serena Hotel Islamabad',
        hotelImageUrl: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?ixlib=rb-4.0.3&w=1000&q=80',
        location: 'Islamabad',
        checkInDate: DateTime.now().add(const Duration(days: 5)),
        checkOutDate: DateTime.now().add(const Duration(days: 8)),
        guests: 2,
        rooms: 1,
        totalAmount: 15000,
        status: 'upcoming',
        bookingDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      // Sample car booking
      CarBooking(
        id: 'c1',
        userId: userId,
        carId: 'car1',
        carName: 'Toyota Corolla',
        carType: 'Sedan',
        carImageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?ixlib=rb-4.0.3&w=1000&q=80',
        carPricePerKm: 25,
        pickupCity: 'Islamabad',
        dropoffCity: 'Lahore',
        pickupDate: DateTime.now().subtract(const Duration(days: 3)),
        dropoffDate: DateTime.now().subtract(const Duration(days: 1)),
        pickupTime: '10:00',
        totalDays: 2,
        totalDistance: 380,
        totalAmount: 19000,
        status: 'completed',
        bookingDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    if (allBookings.isEmpty) {
      return _buildEmptyState();
    }

    // Sort by booking date (newest first)
    allBookings.sort((a, b) {
      DateTime aDate = a is Booking ? a.bookingDate :
      a is HotelBooking ? a.bookingDate :
      (a as CarBooking).bookingDate;
      DateTime bDate = b is Booking ? b.bookingDate :
      b is HotelBooking ? b.bookingDate :
      (b as CarBooking).bookingDate;
      return bDate.compareTo(aDate);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allBookings.length,
      itemBuilder: (context, index) {
        final booking = allBookings[index];
        if (booking is Booking) {
          return _buildTourBookingCard(booking);
        } else if (booking is HotelBooking) {
          return _buildHotelBookingCard(booking);
        } else {
          return _buildCarBookingCard(booking as CarBooking);
        }
      },
    );
  }

  Widget _buildTourBookings(String userId) {
    return StreamBuilder<List<Booking>>(
      stream: _bookingService.getUserBookings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return _buildEmptyTourState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return _buildTourBookingCard(bookings[index]);
          },
        );
      },
    );
  }

  Widget _buildHotelBookings(String userId) {
    final List<HotelBooking> hotelBookings = [
      HotelBooking(
        id: 'h1',
        userId: userId,
        hotelId: 'hotel1',
        hotelName: 'Serena Hotel Islamabad',
        hotelImageUrl: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?ixlib=rb-4.0.3&w=1000&q=80',
        location: 'Islamabad',
        checkInDate: DateTime.now().add(const Duration(days: 5)),
        checkOutDate: DateTime.now().add(const Duration(days: 8)),
        guests: 2,
        rooms: 1,
        totalAmount: 15000,
        status: 'upcoming',
        bookingDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HotelBooking(
        id: 'h2',
        userId: userId,
        hotelId: 'hotel2',
        hotelName: 'Pearl Continental Lahore',
        hotelImageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?ixlib=rb-4.0.3&w=1000&q=80',
        location: 'Lahore',
        checkInDate: DateTime.now().subtract(const Duration(days: 10)),
        checkOutDate: DateTime.now().subtract(const Duration(days: 7)),
        guests: 3,
        rooms: 2,
        totalAmount: 36000,
        status: 'completed',
        bookingDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    if (hotelBookings.isEmpty) {
      return _buildEmptyHotelState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hotelBookings.length,
      itemBuilder: (context, index) {
        return _buildHotelBookingCard(hotelBookings[index]);
      },
    );
  }

  Widget _buildCarBookings(String userId) {
    final List<CarBooking> carBookings = [
      CarBooking(
        id: 'c1',
        userId: userId,
        carId: 'car1',
        carName: 'Toyota Corolla',
        carType: 'Sedan',
        carImageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?ixlib=rb-4.0.3&w=1000&q=80',
        carPricePerKm: 25,
        pickupCity: 'Islamabad',
        dropoffCity: 'Lahore',
        pickupDate: DateTime.now().subtract(const Duration(days: 3)),
        dropoffDate: DateTime.now().subtract(const Duration(days: 1)),
        pickupTime: '10:00',
        totalDays: 2,
        totalDistance: 380,
        totalAmount: 19000,
        status: 'completed',
        bookingDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CarBooking(
        id: 'c2',
        userId: userId,
        carId: 'car2',
        carName: 'Honda Civic',
        carType: 'Sedan',
        carImageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?ixlib=rb-4.0.3&w=1000&q=80',
        carPricePerKm: 28,
        pickupCity: 'Karachi',
        dropoffCity: 'Hyderabad',
        pickupDate: DateTime.now().add(const Duration(days: 3)),
        dropoffDate: DateTime.now().add(const Duration(days: 4)),
        pickupTime: '14:30',
        totalDays: 1,
        totalDistance: 160,
        totalAmount: 4480,
        status: 'upcoming',
        bookingDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    if (carBookings.isEmpty) {
      return _buildEmptyCarState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: carBookings.length,
      itemBuilder: (context, index) {
        return _buildCarBookingCard(carBookings[index]);
      },
    );
  }

  Widget _buildTourBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showTourBookingDetails(booking);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.airplane_ticket, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.destinationName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tour Package',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKR ${booking.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      _formatDateWithMonth(booking.bookingDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelBookingCard(HotelBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showHotelBookingDetails(booking);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(booking.hotelImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.hotelName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.location,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDateWithMonth(booking.checkInDate)} - ${_formatDateWithMonth(booking.checkOutDate)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.guests} Guest${booking.guests > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKR ${booking.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      _formatDateWithMonth(booking.bookingDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarBookingCard(CarBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showCarBookingDetails(booking);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(booking.carImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.carName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.pickupCity} → ${booking.dropoffCity}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDateWithMonth(booking.pickupDate)} • ${booking.pickupTime}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.totalDays} Day${booking.totalDays > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKR ${booking.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      _formatDateWithMonth(booking.bookingDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your bookings...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.beach_access, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Please login to view your bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to see your tour bookings and history',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
            },
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.airplane_ticket, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Bookings Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your adventure by booking your first tour!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Explore Tours'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTourState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.airplane_ticket, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Tour Bookings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t booked any tours yet',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHotelState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hotel, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Hotel Bookings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t booked any hotels yet',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCarState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Car Bookings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t booked any cars yet',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'upcoming':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'upcoming':
        return 'Upcoming';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  void _showTourBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tour Booking Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Destination', booking.destinationName),
                    _buildDetailRow('Guests', '${booking.guests} person(s)'),
                    _buildDetailRow('Status', _getStatusText(booking.status),
                        valueColor: _getStatusColor(booking.status)),
                    _buildDetailRow('Total Price', 'PKR ${booking.totalPrice.toStringAsFixed(0)}'),
                    _buildDetailRow('Booking Date', _formatDateWithMonth(booking.bookingDate)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHotelBookingDetails(HotelBooking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hotel Booking Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Hotel', booking.hotelName),
                    _buildDetailRow('Location', booking.location),
                    _buildDetailRow('Check-in', _formatDateWithMonth(booking.checkInDate)),
                    _buildDetailRow('Check-out', _formatDateWithMonth(booking.checkOutDate)),
                    _buildDetailRow('Guests', '${booking.guests} person(s)'),
                    _buildDetailRow('Rooms', '${booking.rooms} room(s)'),
                    _buildDetailRow('Status', _getStatusText(booking.status),
                        valueColor: _getStatusColor(booking.status)),
                    _buildDetailRow('Total Amount', 'PKR ${booking.totalAmount.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarBookingDetails(CarBooking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Car Booking Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Car', booking.carName),
                    _buildDetailRow('Type', booking.carType),
                    _buildDetailRow('Route', '${booking.pickupCity} → ${booking.dropoffCity}'),
                    _buildDetailRow('Pickup Date', _formatDateWithMonth(booking.pickupDate)),
                    _buildDetailRow('Pickup Time', booking.pickupTime),
                    _buildDetailRow('Duration', '${booking.totalDays} day(s)'),
                    _buildDetailRow('Distance', '${booking.totalDistance.toStringAsFixed(0)} km'),
                    _buildDetailRow('Status', _getStatusText(booking.status),
                        valueColor: _getStatusColor(booking.status)),
                    _buildDetailRow('Total Amount', 'PKR ${booking.totalAmount.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}