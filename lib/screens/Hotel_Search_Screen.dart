import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import 'payment_screen.dart'; // ✅ Add payment screen import

class AllPakistanHotelBookingScreen extends StatefulWidget {
  @override
  State<AllPakistanHotelBookingScreen> createState() => _AllPakistanHotelBookingScreenState();
}

class _AllPakistanHotelBookingScreenState extends State<AllPakistanHotelBookingScreen> {
  String? _selectedCity;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  int _rooms = 1;

  final List<String> _pakistanCities = [
    'Islamabad', 'Rawalpindi', 'Lahore', 'Karachi', 'Peshawar',
    'Quetta', 'Faisalabad', 'Multan', 'Hyderabad', 'Gujranwala',
    'Sialkot', 'Bahawalpur', 'Sargodha', 'Sukkur', 'Larkana',
    'Sheikhupura', 'Jhang', 'Rahim Yar Khan', 'Gujrat', 'Mardan',
    'Kasur', 'Dera Ghazi Khan', 'Sahiwal', 'Nawabshah', 'Mirpur Khas',
    'Okara', 'Mingora', 'Chiniot', 'Kamoke', 'Hafizabad',
    'Gilgit', 'Skardu', 'Chitral', 'Abbottabad', 'Mansehra',
    'Swat', 'Naran', 'Kaghan', 'Hunza', 'Fairy Meadows'
  ];

  List<Hotel> _filteredHotels = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pakistan Hotels Booking'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Filters
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // City Selection
                _buildCityDropdown(),
                SizedBox(height: 12),

                // Date Selection
                Row(
                  children: [
                    Expanded(child: _buildDatePicker('Check-in', _checkInDate, _selectCheckInDate)),
                    SizedBox(width: 12),
                    Expanded(child: _buildDatePicker('Check-out', _checkOutDate, _selectCheckOutDate)),
                  ],
                ),
                SizedBox(height: 12),

                // Guests and Rooms
                Row(
                  children: [
                    Expanded(child: _buildCounter('Guests', _guests, _updateGuests)),
                    SizedBox(width: 12),
                    Expanded(child: _buildCounter('Rooms', _rooms, _updateRooms)),
                  ],
                ),
                SizedBox(height: 16),

                // Search Button
                ElevatedButton(
                  onPressed: _searchHotels,
                  child: Text('Search Hotels'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _filteredHotels.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Select city and dates to search hotels',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredHotels.length,
              itemBuilder: (context, index) {
                return _buildHotelCard(_filteredHotels[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCity,
            isExpanded: true,
            underline: SizedBox(),
            hint: Text('Select City'),
            items: _pakistanCities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function() onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select $label',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onUpdate(value - 1),
                icon: Icon(Icons.remove),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => onUpdate(value + 1),
                icon: Icon(Icons.add),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          // Hotel Image
          Container(
            height: 200,
            width: double.infinity,
            child: Image.network(
              hotel.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Hotel Image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),

          // Hotel Details
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hotel.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            hotel.rating.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),
                Text(hotel.location, style: TextStyle(color: Colors.grey)),

                SizedBox(height: 8),
                Text(
                  hotel.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),

                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: hotel.amenities.take(3).map((amenity) {
                    return Chip(
                      label: Text(amenity),
                      backgroundColor: Colors.purple[50],
                      labelStyle: TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ),

                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${hotel.pricePerNight.toStringAsFixed(0)}/night',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _bookHotel(hotel),
                      child: Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: _checkInDate ?? DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  void _updateGuests(int newValue) {
    if (newValue >= 1 && newValue <= 10) {
      setState(() {
        _guests = newValue;
      });
    }
  }

  void _updateRooms(int newValue) {
    if (newValue >= 1 && newValue <= 5) {
      setState(() {
        _rooms = newValue;
      });
    }
  }

  void _searchHotels() {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a city')),
      );
      return;
    }

    // Filter hotels based on selected city
    setState(() {
      _filteredHotels = _getHotelsByCity(_selectedCity!);
    });
  }

  List<Hotel> _getHotelsByCity(String city) {
    // Sample hotel data
    return [
      Hotel(
        id: '1',
        name: 'Serena Hotel $city',
        destinationId: '1',
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?ixlib=rb-4.0.3&w=1000&q=80',
        location: 'Main Boulevard, $city',
        pricePerNight: 15000,
        description: 'Luxury 5-star hotel in the heart of $city with world-class amenities and services.',
        amenities: ['Free WiFi', 'Swimming Pool', 'Spa', 'Restaurant', 'Gym', 'Parking'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '2',
        name: 'Pearl Continental $city',
        destinationId: '1',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?ixlib=rb-4.0.3&w=1000&q=80',
        location: 'City Center, $city',
        pricePerNight: 12000,
        description: 'Premium hotel with excellent amenities and convenient location in $city.',
        amenities: ['Free WiFi', 'Gym', 'Restaurant', 'Parking', 'Room Service'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '3',
        name: 'Hotel One $city',
        destinationId: '1',
        rating: 4.2,
        imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&w=1000&q=80',
        location: 'Commercial Area, $city',
        pricePerNight: 8000,
        description: 'Comfortable business hotel with modern facilities in $city.',
        amenities: ['Free WiFi', 'Restaurant', 'Parking', 'Business Center'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '4',
        name: 'Ramada $city',
        destinationId: '1',
        rating: 4.4,
        imageUrl: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?ixlib=rb-4.0.3&w=1000&q=80',
        location: 'Downtown $city',
        pricePerNight: 10000,
        description: 'International standard hotel with premium services in $city.',
        amenities: ['Free WiFi', 'Swimming Pool', 'Restaurant', 'Spa', 'Gym'],
        category: '4 Star Premium',
      ),
    ];
  }

  // ✅ UPDATED: _bookHotel method with navigation to Payment Screen
  void _bookHotel(Hotel hotel) {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select check-in and check-out dates')),
      );
      return;
    }

    // Calculate total nights and amount
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalAmount = hotel.pricePerNight * nights * _rooms;

    // Prepare booking details for payment screen
    Map<String, dynamic> bookingDetails = {
      'hotelName': hotel.name,
      'location': hotel.location,
      'checkInDate': '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
      'checkOutDate': '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}',
      'guests': _guests,
      'rooms': _rooms,
      'totalNights': nights,
      'pricePerNight': hotel.pricePerNight,
      'totalAmount': totalAmount,
      'hotelCategory': hotel.category,
      'hotelRating': hotel.rating,
      'hotelAmenities': hotel.amenities,
    };

    // Navigate to Payment Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingType: 'hotel',
          bookingData: bookingDetails,
        ),
      ),
    );
  }
}