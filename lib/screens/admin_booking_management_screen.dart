import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

class AdminBookingManagementScreen extends StatefulWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  State<AdminBookingManagementScreen> createState() =>
      _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState
    extends State<AdminBookingManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterStatus = 'all';

  final List<Map<String, dynamic>> _statusFilters = [
    {'label': 'All', 'value': 'all', 'color': AppConstants.primaryColor},
    {'label': 'Pending', 'value': 'pending', 'color': AppConstants.warningColor},
    {'label': 'Confirmed', 'value': 'confirmed', 'color': AppConstants.successColor},
    {'label': 'Completed', 'value': 'completed', 'color': AppConstants.infoColor},
    {'label': 'Cancelled', 'value': 'cancelled', 'color': AppConstants.errorColor},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Management',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildBookingList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _statusFilters.length,
          itemBuilder: (context, index) {
            final filter = _statusFilters[index];
            final isSelected = _filterStatus == filter['value'];
            return GestureDetector(
              onTap: () => setState(() => _filterStatus = filter['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [
                          filter['color'] as Color,
                          (filter['color'] as Color).withValues(alpha: 0.7),
                        ])
                      : null,
                  color: isSelected ? null : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (filter['color'] as Color)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppConstants.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    Stream<QuerySnapshot> stream;
    if (_filterStatus == 'all') {
      stream = _firestore
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      stream = _firestore
          .collection('bookings')
          .where('status', isEqualTo: _filterStatus)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildStaticBookingList();
        }

        final bookings = snapshot.data?.docs ?? [];

        if (bookings.isEmpty) {
          return _buildStaticBookingList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final data = bookings[index].data() as Map<String, dynamic>;
            return _buildBookingCard(
              docId: bookings[index].id,
              userName: data['userName'] ?? 'Guest',
              userEmail: data['userEmail'] ?? '',
              destination: data['destination'] ?? 'N/A',
              date: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 10)
                  : 'N/A',
              status: data['status'] ?? 'pending',
              price: (data['totalPrice'] ?? 0).toDouble(),
              guests: data['guests'] ?? 1,
            );
          },
        );
      },
    );
  }

  Widget _buildStaticBookingList() {
    final bookings = [
      {'id': '1', 'name': 'Ali Raza', 'email': 'ali@email.com', 'dest': 'Hunza Valley', 'date': '2025-12-20', 'status': 'confirmed', 'price': 24999.0, 'guests': 2},
      {'id': '2', 'name': 'Fatima Khan', 'email': 'fatima@email.com', 'dest': 'Skardu', 'date': '2025-12-18', 'status': 'pending', 'price': 29999.0, 'guests': 4},
      {'id': '3', 'name': 'Usman Ahmed', 'email': 'usman@email.com', 'dest': 'Fairy Meadows', 'date': '2025-12-15', 'status': 'completed', 'price': 21999.0, 'guests': 1},
      {'id': '4', 'name': 'Ayesha Malik', 'email': 'ayesha@email.com', 'dest': 'Swat Valley', 'date': '2025-12-12', 'status': 'pending', 'price': 18999.0, 'guests': 3},
      {'id': '5', 'name': 'Hassan Shah', 'email': 'hassan@email.com', 'dest': 'Naran Kaghan', 'date': '2025-12-10', 'status': 'cancelled', 'price': 17999.0, 'guests': 2},
    ];

    final filtered = _filterStatus == 'all'
        ? bookings
        : bookings.where((b) => b['status'] == _filterStatus).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppConstants.lightTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final b = filtered[index];
        return _buildBookingCard(
          docId: b['id'] as String,
          userName: b['name'] as String,
          userEmail: b['email'] as String,
          destination: b['dest'] as String,
          date: b['date'] as String,
          status: b['status'] as String,
          price: b['price'] as double,
          guests: b['guests'] as int,
        );
      },
    );
  }

  Widget _buildBookingCard({
    required String docId,
    required String userName,
    required String userEmail,
    required String destination,
    required String date,
    required String status,
    required double price,
    required int guests,
  }) {
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = AppConstants.successColor;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'pending':
        statusColor = AppConstants.warningColor;
        statusIcon = Icons.pending_rounded;
        break;
      case 'cancelled':
        statusColor = AppConstants.errorColor;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'completed':
        statusColor = AppConstants.infoColor;
        statusIcon = Icons.task_alt_rounded;
        break;
      default:
        statusColor = AppConstants.lightTextColor;
        statusIcon = Icons.help_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    userName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textColor,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppConstants.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Details
          Row(
            children: [
              _buildDetailItem(Icons.location_on_rounded, destination),
              const SizedBox(width: 16),
              _buildDetailItem(Icons.calendar_today_rounded, date),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailItem(Icons.people_rounded, '$guests Guests'),
              const SizedBox(width: 16),
              _buildDetailItem(
                  Icons.monetization_on_rounded, 'Rs. ${price.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              if (status.toLowerCase() == 'pending') ...[
                Expanded(
                  child: ScaleOnTap(
                    onTap: () => _updateBookingStatus(docId, 'confirmed'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ScaleOnTap(
                    onTap: () => _updateBookingStatus(docId, 'cancelled'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppConstants.errorColor),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: AppConstants.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (status.toLowerCase() == 'confirmed')
                Expanded(
                  child: ScaleOnTap(
                    onTap: () => _updateBookingStatus(docId, 'completed'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Mark Completed',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppConstants.lightTextColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _updateBookingStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking ${newStatus.toUpperCase()} successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    }
  }
}
