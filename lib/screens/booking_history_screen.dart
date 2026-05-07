// screens/booking_history_screen.dart
import 'package:flutter/material.dart';
import '../services/local_booking_store.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  int _selectedTab = 0; // 0: All, 1: Tours, 2: Hotels, 3: Cars

  String _formatDateWithMonth(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<LocalBooking> _filterLocalBookings() {
    final all = LocalBookingStore.instance.bookings;
    switch (_selectedTab) {
      case 1:
        return all.where((b) => b.type == 'tour').toList();
      case 2:
        return all.where((b) => b.type == 'hotel').toList();
      case 3:
        return all.where((b) => b.type == 'car').toList();
      default:
        return all;
    }
  }

  IconData _iconForBookingType(String type) {
    switch (type) {
      case 'tour':
        return Icons.airline_stops_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  Color _colorForBookingType(String type) {
    switch (type) {
      case 'tour':
        return Colors.deepPurple;
      case 'hotel':
        return Colors.orange;
      case 'car':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  Widget _buildLocalBookingCard(LocalBooking booking) {
    final color = _colorForBookingType(booking.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconForBookingType(booking.type), color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  booking.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateWithMonth(booking.bookingDate),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${booking.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.paymentMethod,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
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
            child: AnimatedBuilder(
              animation: LocalBookingStore.instance,
              builder: (context, _) {
                final localBookings = _filterLocalBookings();
                if (localBookings.isEmpty) {
                  return _buildGuestState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: localBookings.length,
                  itemBuilder: (context, index) =>
                      _buildLocalBookingCard(localBookings[index]),
                );
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
}
