import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_model.dart';
import '../models/hotel_model.dart';
import '../widgets/custom_button.dart';
import 'transport_selection_screen.dart';
import '../widgets/cached_image.dart';

class HotelSelectionScreen extends StatefulWidget {
  final Destination destination;

  const HotelSelectionScreen({Key? key, required this.destination}) : super(key: key);

  @override
  State<HotelSelectionScreen> createState() => _HotelSelectionScreenState();
}

class _HotelSelectionScreenState extends State<HotelSelectionScreen> {
  Hotel? _selectedHotel;
  List<Hotel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHotelsFromFirestore();
  }

  Future<void> _fetchHotelsFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('destinationId', isEqualTo: widget.destination.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _hotels = querySnapshot.docs.map((doc) {
            final data = doc.data();
            return Hotel(
              id: doc.id,
              name: data['name'] ?? '',
              destinationId: data['destinationId'] ?? '',
              rating: (data['rating'] ?? 0.0).toDouble(),
              imageUrl: data['imageUrl'] ?? '',
              location: data['location'] ?? '',
              pricePerNight: (data['pricePerNight'] ?? 0).toDouble(),
              description: data['description'] ?? '',
              amenities: List<String>.from(data['amenities'] ?? []),
              category: data['category'] ?? '',
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        // Fallback to temp hotels if no data in Firestore
        setState(() {
          _hotels = _getTempHotels();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching hotels: $e');
      setState(() {
        _hotels = _getTempHotels();
        _isLoading = false;
      });
    }
  }

  List<Hotel> _getTempHotels() {
    // ✅ FIXED WORKING HOTEL IMAGES
    final luxuryHotelImages = [
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?ixlib=rb-4.0.3&w=1000&q=80',
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?ixlib=rb-4.0.3&w=1000&q=80',
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?ixlib=rb-4.0.3&w=1000&q=80',
    ];

    final standardHotelImages = [
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&w=1000&q=80',
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?ixlib=rb-4.0.3&w=1000&q=80',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-4.0.3&w=1000&q=80',
    ];

    final campingImages = [
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1000&q=80',
      'https://images.unsplash.com/photo-1504851149312-7a075b496cc7?ixlib=rb-4.0.3&w=1000&q=80',
      'https://images.unsplash.com/photo-1539185441755-769473a23570?ixlib=rb-4.0.3&w=1000&q=80',
    ];

    return [
      // ✅ Hunza Valley Hotels (destinationId: '1')
      Hotel(
        id: '1',
        name: 'Serena Hotel Hunza',
        destinationId: '1',
        rating: 4.8,
        imageUrl: luxuryHotelImages[0],
        location: 'Karimabad, Hunza, Gilgit-Baltistan',
        pricePerNight: 25000,
        description: 'Luxury hotel with breathtaking views of Rakaposhi and Ultar Sar peaks. World-class amenities and traditional hospitality.',
        amenities: ['Free WiFi', 'Fine Dining', 'Mountain View', 'Spa', 'Heated Pool', 'Garden', '24/7 Service'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '2',
        name: 'Eagle\'s Nest Hotel',
        destinationId: '1',
        rating: 4.6,
        imageUrl: luxuryHotelImages[1],
        location: 'Duikar, Hunza, Gilgit-Baltistan',
        pricePerNight: 15000,
        description: 'Highest point in Hunza offering panoramic views of entire valley. Perfect for sunrise and sunset photography.',
        amenities: ['Panoramic View', 'Restaurant', 'Free Parking', 'Tour Desk', 'Sunset Point'],
        category: '4 Star Premium',
      ),
      Hotel(
        id: '3',
        name: 'Hunza Embassy Hotel',
        destinationId: '1',
        rating: 4.3,
        imageUrl: standardHotelImages[0],
        location: 'Karimabad, Hunza, Gilgit-Baltistan',
        pricePerNight: 12000,
        description: 'Comfortable hotel in central Karimabad with easy access to local markets and attractions.',
        amenities: ['Free WiFi', 'Restaurant', 'Mountain View', 'Hot Water', 'Room Service'],
        category: '3 Star Standard',
      ),

      // ✅ Skardu Hotels (destinationId: '2')
      Hotel(
        id: '4',
        name: 'Shangrila Resort Skardu',
        destinationId: '2',
        rating: 4.7,
        imageUrl: luxuryHotelImages[2],
        location: 'Upper Kachura, Skardu, Gilgit-Baltistan',
        pricePerNight: 22000,
        description: 'Iconic luxury resort with stunning Shangrila Lake view and premium world-class amenities.',
        amenities: ['Lake View', 'Swimming Pool', 'Spa', 'Boating', 'Fine Dining', 'Kids Area'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '5',
        name: 'PTDC Motel Skardu',
        destinationId: '2',
        rating: 4.2,
        imageUrl: standardHotelImages[1],
        location: 'Skardu City, Gilgit-Baltistan',
        pricePerNight: 11000,
        description: 'Comfortable government hotel with essential amenities and strategic location for tourists.',
        amenities: ['Restaurant', 'Parking', 'Tour Desk', '24/7 Service', 'City Center'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '6',
        name: 'Baltoro Hotel Skardu',
        destinationId: '2',
        rating: 4.1,
        imageUrl: standardHotelImages[2],
        location: 'Skardu Road, Gilgit-Baltistan',
        pricePerNight: 13000,
        description: 'Modern hotel catering to both tourists and mountaineers heading to K2 base camp.',
        amenities: ['Free WiFi', 'Restaurant', 'Mountain Gear Storage', 'Hot Water', 'Travel Desk'],
        category: '3 Star Standard',
      ),

      // ✅ Fairy Meadows Hotels (destinationId: '3')
      Hotel(
        id: '7',
        name: 'Fairy Meadows Resort',
        destinationId: '3',
        rating: 4.5,
        imageUrl: campingImages[0],
        location: 'Fairy Meadows, Gilgit-Baltistan',
        pricePerNight: 18000,
        description: 'Luxury camping resort with direct breathtaking views of Nanga Parbat. Once-in-a-lifetime experience with comfortable tents.',
        amenities: ['Nanga Parbat View', 'Luxury Tents', 'Bonfire', 'Guide Services', 'Restaurant', 'Hot Water'],
        category: '4 Star Premium',
      ),
      Hotel(
        id: '8',
        name: 'Beyal Camp',
        destinationId: '3',
        rating: 4.4,
        imageUrl: campingImages[1],
        location: 'Beyal Camp, Fairy Meadows',
        pricePerNight: 15000,
        description: 'Adventure camp offering luxury tented accommodation with breathtaking mountain views and professional trekking guides.',
        amenities: ['Luxury Tents', 'Mountain View', 'Bonfire', 'Trekking Guides', 'Restaurant', 'Solar Power'],
        category: '4 Star Premium',
      ),
      Hotel(
        id: '9',
        name: 'Raikot Serai Hotel',
        destinationId: '3',
        rating: 4.2,
        imageUrl: campingImages[2],
        location: 'Raikot Bridge, Gilgit-Baltistan',
        pricePerNight: 12000,
        description: 'Base camp hotel for Fairy Meadows trek with comfortable accommodations, trek planning, and mountain gear storage.',
        amenities: ['Trek Planning', 'Restaurant', 'Parking', 'Guide Services', 'Mountain Gear', 'Hot Water'],
        category: '3 Star Standard',
      ),

      // ✅ Swat Valley Hotels (destinationId: '4')
      Hotel(
        id: '10',
        name: 'Swat Serena Hotel',
        destinationId: '4',
        rating: 4.6,
        imageUrl: luxuryHotelImages[0],
        location: 'Mingora, Swat, KPK',
        pricePerNight: 20000,
        description: 'Luxury 5-star hotel in the heart of Swat Valley with beautiful garden views, swimming pool, and premium services.',
        amenities: ['Swimming Pool', 'Spa', 'Fine Dining', 'Conference Hall', 'Kids Club', 'Free WiFi', '24/7 Room Service'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '11',
        name: 'Rock City Hotel & Resort',
        destinationId: '4',
        rating: 4.3,
        imageUrl: luxuryHotelImages[1],
        location: 'Mingora, Swat, KPK',
        pricePerNight: 14000,
        description: 'Modern hotel with excellent facilities, comfortable rooms, and convenient location for exploring Swat Valley.',
        amenities: ['Free WiFi', 'Restaurant', 'Parking', 'Room Service', 'Tour Desk', 'Garden', 'Heating'],
        category: '4 Star Premium',
      ),
      Hotel(
        id: '12',
        name: 'Malam Jabba Resort',
        destinationId: '4',
        rating: 4.1,
        imageUrl: luxuryHotelImages[2],
        location: 'Malam Jabba, Swat, KPK',
        pricePerNight: 11000,
        description: 'Picturesque resort in Malam Jabba with stunning valley views and direct access to ski slopes.',
        amenities: ['Ski Access', 'Mountain View', 'Restaurant', 'Heating', 'Adventure Sports', 'Bonfire'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '13',
        name: 'Swat View Hotel',
        destinationId: '4',
        rating: 4.0,
        imageUrl: standardHotelImages[0],
        location: 'Mingora, Swat, KPK',
        pricePerNight: 8500,
        description: 'Comfortable hotel with beautiful Swat Valley views, friendly staff, and essential amenities.',
        amenities: ['Valley View', 'Restaurant', 'Free Parking', 'Room Service', 'Tour Assistance', 'Hot Water'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '14',
        name: 'Swat Continental Hotel',
        destinationId: '4',
        rating: 3.9,
        imageUrl: standardHotelImages[1],
        location: 'Saidu Sharif, Swat, KPK',
        pricePerNight: 7000,
        description: 'Economical hotel in capital city with essential amenities for comfortable stay and easy access to attractions.',
        amenities: ['Restaurant', 'Parking', 'City Center', '24/7 Service', 'Travel Desk', 'Free WiFi'],
        category: '2 Star Budget',
      ),

      // ✅ Naran & Kaghan Hotels (destinationId: '5')
      Hotel(
        id: '15',
        name: 'Pearl Continental Bhurban',
        destinationId: '5',
        rating: 4.7,
        imageUrl: luxuryHotelImages[0],
        location: 'Bhurban, Near Naran, KPK',
        pricePerNight: 28000,
        description: 'Luxury 5-star resort with spectacular mountain views, golf course, and world-class amenities near Naran Valley.',
        amenities: ['Mountain View', 'Golf Course', 'Spa', 'Swimming Pool', 'Fine Dining', 'Kids Club', 'Conference Hall'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '16',
        name: 'Hotel One Naran',
        destinationId: '5',
        rating: 4.4,
        imageUrl: luxuryHotelImages[1],
        location: 'Naran City Center, KPK',
        pricePerNight: 16000,
        description: 'Premium hotel in central Naran with modern amenities, comfortable rooms, and easy access to all attractions.',
        amenities: ['Free WiFi', 'Restaurant', 'Heating', 'Parking', 'Tour Desk', 'Room Service', 'Hot Water'],
        category: '4 Star Premium',
      ),
      Hotel(
        id: '17',
        name: 'Kaghan Continental Hotel',
        destinationId: '5',
        rating: 4.2,
        imageUrl: standardHotelImages[0],
        location: 'Kaghan City Center, KPK',
        pricePerNight: 12000,
        description: 'Comfortable hotel in Kaghan valley with beautiful views, warm hospitality, and essential amenities.',
        amenities: ['Valley View', 'Restaurant', 'Hot Water', 'Parking', 'Travel Assistance', 'Heating'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '18',
        name: 'Naran Park Hotel',
        destinationId: '5',
        rating: 4.1,
        imageUrl: standardHotelImages[1],
        location: 'Naran Valley, KPK',
        pricePerNight: 9500,
        description: 'Cozy hotel surrounded by natural beauty with comfortable accommodations and friendly service.',
        amenities: ['Garden', 'Restaurant', 'Parking', 'Bonfire', 'Tour Arrangements', 'Hot Water'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '19',
        name: 'Saif-ul-Malook Hotel',
        destinationId: '5',
        rating: 3.8,
        imageUrl: standardHotelImages[2],
        location: 'Lake Saif-ul-Malook Road, Naran',
        pricePerNight: 8000,
        description: 'Budget hotel near famous Lake Saif-ul-Malook with basic amenities, great location, and guide services.',
        amenities: ['Lake Access', 'Restaurant', 'Parking', 'Hot Water', 'Guide Services', 'Heating'],
        category: '2 Star Budget',
      ),
      Hotel(
        id: '20',
        name: 'Royal Hotel Naran',
        destinationId: '5',
        rating: 4.0,
        imageUrl: standardHotelImages[0],
        location: 'Naran Bazaar, KPK',
        pricePerNight: 10000,
        description: 'Well-maintained hotel in central Naran with comfortable rooms, good service, and convenient location.',
        amenities: ['Restaurant', 'Parking', 'Heating', 'Hot Water', 'Travel Desk', 'Free WiFi'],
        category: '3 Star Standard',
      ),
    ];
  }

  // Filter hotels based on selected destination
  List<Hotel> get _filteredHotels {
    return _hotels.where((hotel) => hotel.destinationId == widget.destination.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hotels in ${widget.destination.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.hotel, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select your preferred hotel for ${widget.destination.name}. All prices are per night.',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hotel Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Text(
                  '${_filteredHotels.length} hotels found',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredHotels.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredHotels.length,
              itemBuilder: (context, index) {
                final hotel = _filteredHotels[index];
                return _buildHotelCard(hotel);
              },
            ),
          ),

          // Continue Button
          if (_selectedHotel != null)
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
                        'Selected Hotel:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        _selectedHotel!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
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
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(_selectedHotel!.category),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _selectedHotel!.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'Continue to Transport - Rs. ${_selectedHotel!.pricePerNight.toStringAsFixed(0)}/night',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransportSelectionScreen(
                            destination: widget.destination,
                            selectedHotel: _selectedHotel!,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading hotels...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
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
          Icon(Icons.hotel, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hotels available for ${widget.destination.name}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Destination ID: ${widget.destination.id}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    bool isSelected = _selectedHotel?.id == hotel.id;

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
        border: isSelected
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedHotel = hotel;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Image with CachedImage
                Stack(
                  children: [
                    CachedImage(
                      imageUrl: hotel.imageUrl,
                      width: 120,
                      height: 120,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Category Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(hotel.category),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hotel.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Hotel Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hotel Name and Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hotel.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  hotel.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hotel.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        hotel.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Amenities
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: hotel.amenities.take(3).map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              amenity,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 10,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 8),

                      // Price and Select Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rs. ${hotel.pricePerNight.toStringAsFixed(0)}/night',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                hotel.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getCategoryColor(hotel.category),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),

                          // Selection Indicator
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                              color: isSelected ? Colors.blue : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Category colors function
  Color _getCategoryColor(String category) {
    switch (category) {
      case '5 Star Luxury':
        return Colors.purple;
      case '4 Star Premium':
        return Colors.blue;
      case '3 Star Standard':
        return Colors.green;
      case '2 Star Budget':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}