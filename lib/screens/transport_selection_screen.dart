import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../models/hotel_model.dart';
import '../widgets/custom_button.dart';
import 'payment_screen.dart';

class TransportSelectionScreen extends StatefulWidget {
  final Destination destination;
  final Hotel selectedHotel;

  const TransportSelectionScreen({
    Key? key,
    required this.destination,
    required this.selectedHotel,
  }) : super(key: key);

  @override
  State<TransportSelectionScreen> createState() => _TransportSelectionScreenState();
}

class _TransportSelectionScreenState extends State<TransportSelectionScreen> {
  String? _selectedTransport;

  final List<Map<String, dynamic>> _transportOptions = [
    {
      'id': '1',
      'type': 'Luxury Bus',
      'name': 'Daewoo Express',
      'price': 3500,
      'image': 'https://images.pexels.com/photos/2402648/pexels-photo-2402648.jpeg?auto=compress&cs=tinysrgb&w=600',
      'features': ['AC', 'Comfortable Seats', 'Entertainment', 'Washroom', 'Snacks'],
      'capacity': '40 seats',
      'duration': '12-14 hours',
      'category': 'Economy',
      'vehicleType': 'Bus',
    },
    {
      'id': '2',
      'type': 'Premium Van',
      'name': 'Toyota Hiace',
      'price': 12000,
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/2020_Toyota_HiAce_%28front%29.jpg/600px-2020_Toyota_HiAce_%28front%29.jpg',
      'features': ['AC', '12 Seats', 'Luggage Space', 'Comfortable', 'Privacy'],
      'capacity': '12 seats',
      'duration': '10-12 hours',
      'category': 'Comfort',
      'vehicleType': 'Van',
    },
    {
      'id': '3',
      'type': 'SUV 4x4',
      'name': 'Toyota Fortuner',
      'price': 18000,
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/2015_Toyota_Fortuner_%28New_Zealand%29.jpg/600px-2015_Toyota_Fortuner_%28New_Zealand%29.jpg',
      'features': ['AC', '7 Seats', '4x4', 'Luxury', 'Off-road Capable'],
      'capacity': '7 seats',
      'duration': '8-10 hours',
      'category': 'Luxury',
      'vehicleType': 'SUV',
    },
    {
      'id': '4',
      'type': 'Flight',
      'name': 'PIA Domestic',
      'price': 25000,
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/PIA_Airbus_A320_at_Skardu_International_Airport.jpg/600px-PIA_Airbus_A320_at_Skardu_International_Airport.jpg',
      'features': ['Quick', 'Comfortable', 'Meals', 'Entertainment', 'Priority'],
      'capacity': 'Economy Class',
      'duration': '1 hour',
      'category': 'Premium',
      'vehicleType': 'Airplane',
    },
    {
      'id': '5',
      'type': 'Jeep 4x4',
      'name': 'Toyota Land Cruiser',
      'price': 15000,
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/2021_Toyota_Land_Cruiser_300_3.4_ZX_%28Colombia%29_front_view_04.png/600px-2021_Toyota_Land_Cruiser_300_3.4_ZX_%28Colombia%29_front_view_04.png',
      'features': ['4x4', 'Off-road', 'Adventure', 'Mountain Ready', 'Experienced Driver'],
      'capacity': '5 seats',
      'duration': 'Varies by route',
      'category': 'Adventure',
      'vehicleType': 'Jeep',
    },
    {
      'id': '6',
      'type': 'Coaster Bus',
      'name': 'Toyota Coaster',
      'price': 8000,
      'image': 'https://images.pexels.com/photos/385998/pexels-photo-385998.jpeg?auto=compress&cs=tinysrgb&w=600',
      'features': ['AC', '26 Seats', 'Spacious', 'Comfortable', 'Luggage Space'],
      'capacity': '26 seats',
      'duration': '12-14 hours',
      'category': 'Comfort',
      'vehicleType': 'Bus',
    },
    {
      'id': '7',
      'type': 'Private Car',
      'name': 'Honda Civic',
      'price': 10000,
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/2022_Honda_Civic_Touring_in_Lunar_Silver_Metallic%2C_Front_Left%2C_05-10-2022.jpg/600px-2022_Honda_Civic_Touring_in_Lunar_Silver_Metallic%2C_Front_Left%2C_05-10-2022.jpg',
      'features': ['AC', '5 Seats', 'Privacy', 'Comfortable', 'Fuel Efficient'],
      'capacity': '5 seats',
      'duration': '10-12 hours',
      'category': 'Comfort',
      'vehicleType': 'Car',
    },
    {
      'id': '8',
      'type': 'Flight Business',
      'name': 'Airblue Business',
      'price': 35000,
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/PIA_Airbus_A320_at_Skardu_International_Airport.jpg/600px-PIA_Airbus_A320_at_Skardu_International_Airport.jpg',
      'features': ['Priority Boarding', 'Luxury Seats', 'Gourmet Meals', 'Entertainment', 'Extra Luggage'],
      'capacity': 'Business Class',
      'duration': '1 hour',
      'category': 'Premium',
      'vehicleType': 'Airplane',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Transport',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              children: [
                Icon(Icons.directions_car, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Travel to ${widget.destination.name}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Hotel: ${widget.selectedHotel.name}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Text(
                  '${_transportOptions.length} transport options available',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Choose your transport option:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                ..._transportOptions.map((transport) => _buildTransportCard(transport)),
              ],
            ),
          ),

          if (_selectedTransport != null)
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selected Transport:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _transportOptions.firstWhere((t) => t['id'] == _selectedTransport)['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTransportCategoryColor(_transportOptions.firstWhere((t) => t['id'] == _selectedTransport)['category']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _transportOptions.firstWhere((t) => t['id'] == _selectedTransport)['category'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  CustomButton(
                    text: 'Continue to Payment - Rs. ${_transportOptions.firstWhere((t) => t['id'] == _selectedTransport)['price'].toString()}',
                    onPressed: () {
                      final selectedTransport = _transportOptions.firstWhere(
                            (t) => t['id'] == _selectedTransport,
                      );

                      // ✅ FIXED: Now using correct PaymentScreen constructor
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            bookingType: 'tour',
                            bookingData: {
                              'hotel': {
                                'name': widget.selectedHotel.name,
                                'price': widget.selectedHotel.pricePerNight,
                                'category': widget.selectedHotel.category,
                              },
                              'vehicle': {
                                'name': selectedTransport['name'],
                                'type': selectedTransport['type'],
                                'price': selectedTransport['price'],
                                'category': selectedTransport['category'],
                              },
                              'pickupLocation': 'Islamabad',
                              'dropoffLocation': widget.destination.location,
                            },
                            tourData: {
                              'tourName': '${widget.destination.duration} Package',
                              'price': widget.destination.price,
                              'duration': widget.destination.duration,
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(Map<String, dynamic> transport) {
    bool isSelected = _selectedTransport == transport['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isSelected
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTransport = transport['id'];
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        transport['image'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getVehicleIcon(transport['vehicleType']),
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    transport['vehicleType'],
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTransportCategoryColor(transport['category']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transport['category'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transport['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  transport['type'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PKR ${transport['price'].toString()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                transport['capacity'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Duration: ${transport['duration']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (transport['features'] as List<dynamic>).take(3).map((feature) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              feature.toString(),
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? Colors.green : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTransportCategoryColor(String category) {
    switch (category) {
      case 'Premium':
        return Colors.purple;
      case 'Luxury':
        return Colors.blue;
      case 'Comfort':
        return Colors.green;
      case 'Adventure':
        return Colors.orange;
      case 'Economy':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'Bus':
        return '🚌';
      case 'Van':
        return '🚐';
      case 'SUV':
        return '🚙';
      case 'Airplane':
        return '✈️';
      case 'Jeep':
        return '🚗';
      case 'Car':
        return '🚘';
      default:
        return '🚗';
    }
  }
}