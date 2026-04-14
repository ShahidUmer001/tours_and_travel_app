import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingType;
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic>? tourData;

  const PaymentScreen({
    Key? key,
    required this.bookingType,
    required this.bookingData,
    this.tourData,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  // Form Controllers for different payment methods
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _cardNameController = TextEditingController();
  TextEditingController _expiryController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();

  TextEditingController _jazzcashNumberController = TextEditingController();
  TextEditingController _jazzcashPinController = TextEditingController();

  TextEditingController _easypaisaNumberController = TextEditingController();
  TextEditingController _easypaisaPinController = TextEditingController();

  TextEditingController _cashInstructionsController = TextEditingController();

  // Get booking details based on booking type
  String _getBookingTitle() {
    switch (widget.bookingType) {
      case 'tour':
        return widget.tourData?['tourName'] ?? 'Tour Package';
      case 'car':
        return widget.bookingData['carName'] ?? 'Car Booking';
      case 'hotel':
        return widget.bookingData['hotelName'] ?? 'Hotel Booking';
      default:
        return 'Booking';
    }
  }

  double _getTotalAmount() {
    switch (widget.bookingType) {
      case 'tour':
        double tourPrice = (widget.tourData?['price'] ?? 0).toDouble();
        double hotelPrice = (widget.bookingData['hotel']?['price'] ?? 0).toDouble();
        double vehiclePrice = (widget.bookingData['vehicle']?['price'] ?? 0).toDouble();
        return tourPrice + hotelPrice + vehiclePrice;
      case 'car':
        return (widget.bookingData['totalAmount'] ?? 0).toDouble();
      case 'hotel':
        return (widget.bookingData['totalAmount'] ?? 0).toDouble();
      default:
        return 0.0;
    }
  }

  // Get booking summary based on type
  List<Widget> _getBookingSummary() {
    switch (widget.bookingType) {
      case 'tour':
        return [
          _buildSummaryRow('Package:', widget.tourData?['tourName'] ?? 'Tour Package'),
          _buildSummaryRow('Duration:', widget.tourData?['duration'] ?? 'N/A'),
          if (widget.bookingData['hotel'] != null)
            _buildSummaryRow('Hotel:', widget.bookingData['hotel']?['name'] ?? 'Hotel'),
          if (widget.bookingData['vehicle'] != null)
            _buildSummaryRow('Transport:', widget.bookingData['vehicle']?['name'] ?? 'Vehicle'),
          _buildSummaryRow('Pickup:', widget.bookingData['pickupLocation'] ?? 'Islamabad'),
          _buildSummaryRow('Dropoff:', widget.bookingData['dropoffLocation'] ?? 'Destination'),
        ];

      case 'car':
        return [
          _buildSummaryRow('Car:', widget.bookingData['carName'] ?? 'Car'),
          _buildSummaryRow('Route:', '${widget.bookingData['pickupCity']} → ${widget.bookingData['dropoffCity']}'),
          _buildSummaryRow('Pickup Date:', widget.bookingData['pickupDate'] ?? 'N/A'),
          _buildSummaryRow('Pickup Time:', widget.bookingData['pickupTime'] ?? 'N/A'),
          _buildSummaryRow('Duration:', '${widget.bookingData['totalDays'] ?? 1} days'),
          _buildSummaryRow('Distance:', '${widget.bookingData['totalDistance'] ?? 0} km'),
          _buildSummaryRow('Type:', widget.bookingData['carType'] ?? 'Standard'),
          _buildSummaryRow('Transmission:', widget.bookingData['transmission'] ?? 'Automatic'),
        ];

      case 'hotel':
        return [
          _buildSummaryRow('Hotel:', widget.bookingData['hotelName'] ?? 'Hotel'),
          _buildSummaryRow('Location:', widget.bookingData['location'] ?? 'N/A'),
          _buildSummaryRow('Check-in:', widget.bookingData['checkInDate'] ?? 'N/A'),
          _buildSummaryRow('Check-out:', widget.bookingData['checkOutDate'] ?? 'N/A'),
          _buildSummaryRow('Guests:', widget.bookingData['guests']?.toString() ?? '1'),
          _buildSummaryRow('Rooms:', widget.bookingData['rooms']?.toString() ?? '1'),
          _buildSummaryRow('Total Nights:', widget.bookingData['totalNights']?.toString() ?? '1'),
          _buildSummaryRow('Price per Night:', 'Rs. ${widget.bookingData['pricePerNight']?.toStringAsFixed(0) ?? '0'}'),
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment - ${_getBookingTitle()}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ..._getBookingSummary(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Payment Methods
            Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                _buildPaymentMethodTile('Credit/Debit Card', 'card', Icons.credit_card),
                _buildPaymentMethodTile('JazzCash', 'jazzcash', Icons.phone_android),
                _buildPaymentMethodTile('EasyPaisa', 'easypaisa', Icons.phone_iphone),
                _buildPaymentMethodTile('Cash on Delivery', 'cash', Icons.money),
              ],
            ),
            SizedBox(height: 20),

            // Payment Form based on selected method
            if (_selectedPaymentMethod != null) _buildPaymentForm(),
            SizedBox(height: 20),

            // Total Amount
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'PKR ${_getTotalAmount().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Pay Now Button
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: _isProcessing ? null : (value) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return _buildCardPaymentForm();
      case 'jazzcash':
        return _buildJazzCashForm();
      case 'easypaisa':
        return _buildEasyPaisaForm();
      case 'cash':
        return _buildCashPaymentForm();
      default:
        return SizedBox();
    }
  }

  Widget _buildCardPaymentForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
                hintText: '1234 5678 9012 3456',
              ),
              keyboardType: TextInputType.number,
              maxLength: 16,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _cardNameController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                border: OutlineInputBorder(),
                hintText: 'John Doe',
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(),
                      hintText: 'MM/YY',
                    ),
                    maxLength: 5,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                      hintText: '123',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJazzCashForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JazzCash Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _jazzcashNumberController,
              decoration: InputDecoration(
                labelText: 'JazzCash Number',
                border: OutlineInputBorder(),
                hintText: '0300 1234567',
                prefixText: '+92 ',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _jazzcashPinController,
              decoration: InputDecoration(
                labelText: 'MPIN',
                border: OutlineInputBorder(),
                hintText: 'Enter your 4-digit MPIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
            SizedBox(height: 8),
            Text(
              'You will receive a confirmation message on your JazzCash number.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEasyPaisaForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EasyPaisa Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _easypaisaNumberController,
              decoration: InputDecoration(
                labelText: 'EasyPaisa Number',
                border: OutlineInputBorder(),
                hintText: '0312 3456789',
                prefixText: '+92 ',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _easypaisaPinController,
              decoration: InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
                hintText: 'Enter your 5-digit PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 5,
            ),
            SizedBox(height: 8),
            Text(
              'You will receive a confirmation message on your EasyPaisa number.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPaymentForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash on Delivery',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Pay in cash when you arrive.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _cashInstructionsController,
              decoration: InputDecoration(
                labelText: 'Special Instructions (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Any special instructions...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    bool isFormValid = _validateForm();

    return ElevatedButton(
      onPressed: (_selectedPaymentMethod != null && isFormValid && !_isProcessing)
          ? _processPayment
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: (_selectedPaymentMethod != null && isFormValid) ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isProcessing
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 10),
          Text('Processing...'),
        ],
      )
          : Text(
        _getPayButtonText(),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getPayButtonText() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return 'PAY WITH CARD';
      case 'jazzcash':
        return 'PAY WITH JAZZCASH';
      case 'easypaisa':
        return 'PAY WITH EASYPAISA';
      case 'cash':
        return 'CONFIRM CASH BOOKING';
      default:
        return 'PAY NOW';
    }
  }

  bool _validateForm() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return _cardNumberController.text.length == 16 &&
            _cardNameController.text.isNotEmpty &&
            _expiryController.text.isNotEmpty &&
            _cvvController.text.length == 3;
      case 'jazzcash':
        return _jazzcashNumberController.text.length == 10 &&
            _jazzcashPinController.text.length == 4;
      case 'easypaisa':
        return _easypaisaNumberController.text.length == 10 &&
            _easypaisaPinController.text.length == 5;
      case 'cash':
        return true;
      default:
        return false;
    }
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(Duration(seconds: 2));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            bookingType: widget.bookingType,
            paymentMethod: _selectedPaymentMethod!,
            totalAmount: _getTotalAmount(),
            bookingTitle: _getBookingTitle(),
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _jazzcashNumberController.dispose();
    _jazzcashPinController.dispose();
    _easypaisaNumberController.dispose();
    _easypaisaPinController.dispose();
    _cashInstructionsController.dispose();
    super.dispose();
  }
}

class BookingSuccessScreen extends StatelessWidget {
  final String bookingType;
  final String paymentMethod;
  final double totalAmount;
  final String bookingTitle;

  const BookingSuccessScreen({
    Key? key,
    required this.bookingType,
    required this.paymentMethod,
    required this.totalAmount,
    required this.bookingTitle,
  }) : super(key: key);

  String _getPaymentMethodText() {
    switch (paymentMethod) {
      case 'card':
        return 'Credit/Debit Card';
      case 'jazzcash':
        return 'JazzCash';
      case 'easypaisa':
        return 'EasyPaisa';
      case 'cash':
        return 'Cash on Delivery';
      default:
        return 'Payment';
    }
  }

  String _getSuccessMessage() {
    switch (bookingType) {
      case 'car':
        return 'Your car has been successfully booked!';
      case 'hotel':
        return 'Your hotel has been successfully booked!';
      case 'tour':
        return 'Your tour has been successfully booked!';
      default:
        return 'Booking confirmed!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmed'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _getSuccessMessage(),
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSuccessRow('Booking:', bookingTitle),
                    _buildSuccessRow('Type:', bookingType.toUpperCase()),
                    _buildSuccessRow('Payment Method:', _getPaymentMethodText()),
                    _buildSuccessRow('Amount Paid:', 'PKR ${totalAmount.toStringAsFixed(2)}'),
                    _buildSuccessRow('Status:', 'Confirmed'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('View Booking'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    child: Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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

  Widget _buildSuccessRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}