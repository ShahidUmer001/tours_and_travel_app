// screens/multi_city_hotel_screen.dart
import 'package:flutter/material.dart';
import '../models/tour_model.dart';
import 'tour_booking_screen.dart';

class MultiCityHotelScreen extends StatefulWidget {
  final TourPackage tourPackage;

  const MultiCityHotelScreen({Key? key, required this.tourPackage}) : super(key: key);

  @override
  State<MultiCityHotelScreen> createState() => _MultiCityHotelScreenState();
}

class _MultiCityHotelScreenState extends State<MultiCityHotelScreen> {
  Map<String, String> _selectedHotels = {};
  Map<String, String> _selectedRoomTypes = {};

  final Map<String, List<Map<String, dynamic>>> _cityHotels = {
    'Hunza': [
      {'name': 'Serena Hotel Hunza', 'price': 25000, 'type': '5 Star Luxury'},
      {'name': 'Eagle\'s Nest Hotel', 'price': 15000, 'type': '4 Star Premium'},
      {'name': 'Hunza Embassy Hotel', 'price': 12000, 'type': '3 Star Standard'},
    ],
    'Skardu': [
      {'name': 'Shangrila Resort Skardu', 'price': 22000, 'type': '5 Star Luxury'},
      {'name': 'PTDC Motel Skardu', 'price': 11000, 'type': '3 Star Standard'},
      {'name': 'Baltoro Hotel Skardu', 'price': 13000, 'type': '3 Star Standard'},
    ],
    'Fairy Meadows': [
      {'name': 'Fairy Meadows Resort', 'price': 18000, 'type': '4 Star Premium'},
      {'name': 'Beyal Camp', 'price': 15000, 'type': 'Adventure Camp'},
    ],
    'Naran': [
      {'name': 'Hotel One Naran', 'price': 16000, 'type': '4 Star Premium'},
      {'name': 'Naran Park Hotel', 'price': 9500, 'type': '3 Star Standard'},
      {'name': 'Saif-ul-Malook Hotel', 'price': 8000, 'type': '2 Star Budget'},
    ],
    'Swat': [
      {'name': 'Swat Serena Hotel', 'price': 20000, 'type': '5 Star Luxury'},
      {'name': 'Rock City Hotel Swat', 'price': 14000, 'type': '4 Star Premium'},
      {'name': 'Swat View Hotel', 'price': 11000, 'type': '3 Star Standard'},
    ],
  };

  final List<String> _roomTypes = [
    'Standard Room',
    'Deluxe Room',
    'Suite',
    'Family Room'
  ];

  @override
  void initState() {
    super.initState();
    // Set default selections
    for (var destination in widget.tourPackage.destinations) {
      if (_cityHotels.containsKey(destination) && _cityHotels[destination]!.isNotEmpty) {
        _selectedHotels[destination] = _cityHotels[destination]!.first['name'];
        _selectedRoomTypes[destination] = _roomTypes.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Hotels - ${widget.tourPackage.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.hotel, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select hotels for each destination in your tour',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),

          // Hotel Selection
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Hotel Selection for Each Destination',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ...widget.tourPackage.destinations.where((dest) =>
                dest != 'Islamabad' && _cityHotels.containsKey(dest)).map((destination) {
                  return _buildDestinationHotelSection(destination);
                }).toList(),

                const SizedBox(height: 20),

                // Total Price
                _buildTotalPrice(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Continue Button - FIXED: CustomButton ki jagah ElevatedButton use karein
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSelectionComplete() ? _proceedToBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue to Booking - Rs. ${_calculateTotalPrice().toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationHotelSection(String destination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              destination,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Hotel Selection
            _buildHotelDropdown(destination),
            const SizedBox(height: 12),

            // Room Type Selection
            _buildRoomTypeDropdown(destination),
            const SizedBox(height: 8),

            // Selected Hotel Details
            if (_selectedHotels[destination] != null)
              _buildHotelDetails(destination),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelDropdown(String destination) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Hotel:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedHotels[destination],
            isExpanded: true,
            underline: const SizedBox(),
            items: _cityHotels[destination]!.map((hotel) {
              return DropdownMenuItem<String>(
                value: hotel['name'],
                child: Text('${hotel['name']} - Rs. ${hotel['price']}'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedHotels[destination] = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTypeDropdown(String destination) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Type:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedRoomTypes[destination],
            isExpanded: true,
            underline: const SizedBox(),
            items: _roomTypes.map((String roomType) {
              return DropdownMenuItem<String>(
                value: roomType,
                child: Text(roomType),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRoomTypes[destination] = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelDetails(String destination) {
    final selectedHotel = _cityHotels[destination]!.firstWhere(
          (hotel) => hotel['name'] == _selectedHotels[destination],
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected: ${selectedHotel['name']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Category: ${selectedHotel['type']}'),
          Text('Price: Rs. ${selectedHotel['price']} per night'),
          Text('Room Type: ${_selectedRoomTypes[destination]}'),
        ],
      ),
    );
  }

  Widget _buildTotalPrice() {
    double totalPrice = _calculateTotalPrice();
    int numberOfNights = _calculateNumberOfNights();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Tour Package', widget.tourPackage.price),
          _buildPriceRow('Hotels (${numberOfNights} nights)', _calculateHotelTotal()),
          const Divider(),
          _buildPriceRow(
            'Total Amount',
            totalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateHotelTotal() {
    double total = 0;
    for (var destination in _selectedHotels.keys) {
      final hotel = _cityHotels[destination]!.firstWhere(
            (h) => h['name'] == _selectedHotels[destination],
      );
      total += hotel['price'];
    }
    return total * _calculateNumberOfNights();
  }

  int _calculateNumberOfNights() {
    // Extract number of nights from duration string
    final match = RegExp(r'(\d+)\s*Days').firstMatch(widget.tourPackage.duration);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1; // Default to 1 night
  }

  double _calculateTotalPrice() {
    return widget.tourPackage.price + _calculateHotelTotal();
  }

  // ✅ SIMPLE FIX: Basic logic use karein
  bool _isSelectionComplete() {
    try {
      // Count how many destinations need hotel selection
      final destinationsNeedingHotels = widget.tourPackage.destinations
          .where((dest) => dest != 'Islamabad' && _cityHotels.containsKey(dest))
          .length;

      // Return true if we have selected hotels for all destinations
      return _selectedHotels.length >= destinationsNeedingHotels;
    } catch (e) {
      return false;
    }
  }

  // ✅ SIMPLE FIX: Basic navigation
  void _proceedToBooking() {
    try {
      // Prepare hotel selections
      List<Map<String, dynamic>> hotelSelections = [];

      for (var destination in _selectedHotels.keys) {
        final hotel = _cityHotels[destination]!.firstWhere(
              (h) => h['name'] == _selectedHotels[destination],
        );

        hotelSelections.add({
          'destination': destination,
          'hotelName': hotel['name'],
          'hotelPrice': hotel['price'],
          'hotelType': hotel['type'],
          'roomType': _selectedRoomTypes[destination],
          'totalNights': _calculateNumberOfNights(),
        });
      }

      // Navigate to tour booking screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TourBookingScreen(
            tourPackage: widget.tourPackage,
            hotelSelections: hotelSelections,
            totalPrice: _calculateTotalPrice(),
          ),
        ),
      );
    } catch (e) {
      // Fallback: Simple navigation without data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TourBookingScreen(
            tourPackage: widget.tourPackage,
            hotelSelections: [],
            totalPrice: widget.tourPackage.price,
          ),
        ),
      );
    }
  }
}