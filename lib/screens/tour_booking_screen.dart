// screens/tour_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tour_model.dart';
import '../services/auth_service.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class TourBookingScreen extends StatefulWidget {
  final TourPackage tourPackage;
  final List<Map<String, dynamic>> hotelSelections;
  final double totalPrice;

  const TourBookingScreen({
    super.key,
    required this.tourPackage,
    required this.hotelSelections,
    required this.totalPrice,
  });

  @override
  State<TourBookingScreen> createState() => _TourBookingScreenState();
}

class _TourBookingScreenState extends State<TourBookingScreen> {
  final AuthService _authService = AuthService();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String _selectedPaymentMethod = 'Credit Card';
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'JazzCash',
    'EasyPaisa',
    'Bank Transfer',
    'Cash on Delivery'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.tourPackage.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? _buildProcessingScreen()
          : _buildBookingForm(),
    );
  }

  Widget _buildProcessingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Processing Your Booking...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Please wait while we confirm your tour'),
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookingSummary(),
          SizedBox(height: 20),
          _buildUserInfoSection(),
          SizedBox(height: 20),
          _buildPaymentSection(),
          SizedBox(height: 30),
          _buildConfirmButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildSummaryRow('Tour Package', widget.tourPackage.name),
            _buildSummaryRow('Duration', widget.tourPackage.duration),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destinations:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.tourPackage.destinations.join(' → '),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Text(
              'Selected Hotels:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.hotelSelections.length,
                itemBuilder: (context, index) {
                  final hotel = widget.hotelSelections[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.hotel, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel['hotelName'],
                                style: TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${hotel['destination']} - ${hotel['roomType']} - Rs. ${hotel['hotelPrice']}/night',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            _buildSummaryRow(
              'Total Amount',
              'Rs. ${widget.totalPrice.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.green : Colors.black,
                fontSize: isTotal ? 18 : 14,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    final user = _authService.currentUser;
    final isGuest = user == null;
    final displayName = _userData?['fullName'] ?? 'Guest User';
    final email = _userData?['email'] ?? user?.email ?? 'Not provided';
    final phone = _userData?['phone'] ?? 'Not provided';

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking For',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isGuest ? Colors.orange[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isGuest ? Icons.person_outline : Icons.verified,
                        size: 16,
                        color: isGuest ? Colors.orange : Colors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isGuest ? 'Guest' : 'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: isGuest ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow('Name', displayName),
            _buildInfoRow('Email', email),
            _buildInfoRow('Phone', phone),
            if (isGuest)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '💡 Tip: Login for faster bookings and to save your information',
                  style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Select your preferred payment method to complete the booking:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Select Payment Method',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: _paymentMethods.map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            if (_selectedPaymentMethod == 'Credit Card' || _selectedPaymentMethod == 'Debit Card')
              _buildCardPaymentInfo(),
            if (_selectedPaymentMethod == 'JazzCash')
              _buildJazzCashPaymentInfo(),
            if (_selectedPaymentMethod == 'EasyPaisa')
              _buildEasyPaisaPaymentInfo(),
            if (_selectedPaymentMethod == 'Bank Transfer')
              _buildBankTransferInfo(),
            if (_selectedPaymentMethod == 'Cash on Delivery')
              _buildCashOnDeliveryInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💳 Card Payment',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
          SizedBox(height: 4),
          Text(
            'You will be redirected to secure payment gateway after confirmation.',
            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildJazzCashPaymentInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📱 JazzCash',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[800]),
          ),
          SizedBox(height: 4),
          Text(
            'Send payment to JazzCash Account: 0310-5959607\nAccount Title: Tours and Travel',
            style: TextStyle(fontSize: 12, color: Colors.red[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildEasyPaisaPaymentInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📱 EasyPaisa',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800]),
          ),
          SizedBox(height: 4),
          Text(
            'Send payment to EasyPaisa Account: 0310-5959607\nAccount Title: Tours and Travel',
            style: TextStyle(fontSize: 12, color: Colors.orange[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏦 Bank Transfer',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
          ),
          SizedBox(height: 4),
          Text(
            'Bank: HBL\nAccount: 12345678901\nTitle: Tours and Travel Pvt Ltd',
            style: TextStyle(fontSize: 12, color: Colors.green[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildCashOnDeliveryInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💰 Cash on Delivery',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[800]),
          ),
          SizedBox(height: 4),
          Text(
            'Pay when you receive the tour confirmation. Our representative will contact you.',
            style: TextStyle(fontSize: 12, color: Colors.purple[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Pay & Confirm Booking - Rs. ${widget.totalPrice.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ✅ UPDATED: _confirmBooking method with destinationId added
  void _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingId = '#T${DateTime.now().millisecondsSinceEpoch}';
      final user = _authService.currentUser;

      // ✅ NAYI BOOKING TIMESTAMP FORMAT MEIN BANAYEIN
      final newBooking = Booking(
        id: bookingId,
        userId: user?.uid ?? 'guest',
        destinationName: widget.tourPackage.name,
        destinationId: 'tour_1', // ✅ SIRF YEH LINE ADD KI HAI
        bookingDate: DateTime.now(), // ✅ DateTime directly
        guests: 1,
        totalPrice: widget.totalPrice,
        status: 'confirmed',
      );

      // ✅ FIREBASE MEIN SAVE KAREIN
      await BookingService().createBooking(newBooking);

      // Success message - booking object pass karein
      _showBookingSuccessDialog(newBooking);

    } catch (e) {
      print('Booking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ UPDATED: _showBookingSuccessDialog method with booking parameter
  void _showBookingSuccessDialog(Booking booking) {
    final user = _authService.currentUser;
    final userName = _userData?['fullName'] ?? user?.displayName ?? 'Guest';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Booking Confirmed!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thank you, $userName! Your tour has been successfully booked.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              _buildSuccessDetail('Booking ID', booking.id),
              _buildSuccessDetail('Tour', booking.destinationName),
              _buildSuccessDetail('Total Paid', 'Rs. ${booking.totalPrice.toStringAsFixed(0)}'),
              _buildSuccessDetail('Payment Method', _selectedPaymentMethod),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📧 Confirmation email sent to ${user?.email ?? 'your email'}',
                      style: TextStyle(color: Colors.blue[800], fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '📱 Tour details & guide contact will be shared 3 days before departure',
                      style: TextStyle(color: Colors.blue[800], fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '⭐ Thank you for choosing Tours and Travel!',
                      style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('Back to Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('View My Bookings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Flexible(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}