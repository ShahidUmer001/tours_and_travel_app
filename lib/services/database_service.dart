import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_model.dart';
import '../models/hotel_model.dart';
import '../models/booking_model.dart';

class DatabaseService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Destinations
  Stream<List<Destination>> getDestinations() {
    return _firestore
        .collection('destinations')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Destination.fromMap(doc.data()))
        .toList());
  }

  Future<Destination?> getDestination(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('destinations')
          .doc(id)
          .get();

      if (doc.exists) {
        return Destination.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting destination: $e');
      return null;
    }
  }

  // Hotels
  Stream<List<Hotel>> getHotels(String destinationId) {
    return _firestore
        .collection('hotels')
        .where('destinationId', isEqualTo: destinationId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Hotel.fromMap(doc.data()))
        .toList());
  }

  // Bookings
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Booking.fromMap(doc.data()))
        .toList());
  }

  Future<bool> createBooking(Booking booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());
      return true;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  // Temporary method for demo - Updated with categories
  List<Hotel> getDemoHotels(String destinationId) {
    return [
      Hotel(
        id: '1',
        name: 'Serena Hotel Shigar Fort',
        destinationId: destinationId,
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600',
        location: 'Shigar Fort, Shigar, Gilgit-Baltistan',
        pricePerNight: 22000,
        description: 'Luxury heritage hotel in restored 17th-century fort with traditional architecture and modern amenities. Experience royal treatment.',
        amenities: ['Free WiFi', 'Fine Dining', 'Heritage Tour', 'Spa', 'Swimming Pool', 'Garden', '24/7 Service'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '2',
        name: 'Eagle\'s Nest Hotel',
        destinationId: destinationId,
        rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600',
        location: 'Duikar, Hunza, Gilgit-Baltistan',
        pricePerNight: 12000,
        description: 'Panoramic views of Hunza Valley from the highest point. Perfect for photography enthusiasts and nature lovers.',
        amenities: ['Mountain View', 'Restaurant', 'Free Parking', 'Tour Desk', 'Sunset Point', 'Photography Spot'],
        category: '4 Star Premium',
      ),
      Hotel(
        id: '3',
        name: 'Shangrila Resort Skardu',
        destinationId: destinationId,
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600',
        location: 'Upper Kachura, Skardu, Gilgit-Baltistan',
        pricePerNight: 18000,
        description: 'Luxury resort with stunning lake view and premium amenities. Ideal for family vacations and romantic getaways.',
        amenities: ['Lake View', 'Swimming Pool', 'Spa', 'Boating', 'Fine Dining', 'Kids Play Area', 'Water Sports'],
        category: '5 Star Luxury',
      ),
      Hotel(
        id: '4',
        name: 'PTDC Motel Hunza',
        destinationId: destinationId,
        rating: 4.2,
        imageUrl: 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=600',
        location: 'Hunza Center, Gilgit-Baltistan',
        pricePerNight: 8000,
        description: 'Government-run hotel with basic amenities and convenient location. Great value for money.',
        amenities: ['Free WiFi', 'Restaurant', 'Parking', 'Tour Guide', '24/7 Service', 'Central Location'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '5',
        name: 'Hunza Embassy Hotel',
        destinationId: destinationId,
        rating: 4.3,
        imageUrl: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=600',
        location: 'Karimabad, Hunza, Gilgit-Baltistan',
        pricePerNight: 9500,
        description: 'Comfortable hotel with friendly staff and great location near local attractions and markets.',
        amenities: ['Free WiFi', 'Restaurant', 'Mountain View', 'Hot Water', 'Room Service', 'Market Access'],
        category: '3 Star Standard',
      ),
      Hotel(
        id: '6',
        name: 'Swat Serena Hotel',
        destinationId: destinationId,
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600',
        location: 'Mingora, Swat, KPK',
        pricePerNight: 15000,
        description: 'Luxury hotel in the heart of Swat Valley with beautiful garden views and premium services.',
        amenities: ['Garden View', 'Swimming Pool', 'Spa', 'Restaurant', 'Conference Hall', 'Kids Club'],
        category: '5 Star Luxury',
      ),
    ];
  }

  // Get demo destinations
  List<Destination> getDemoDestinations() {
    return [
      Destination(
        id: '1',
        name: 'Hunza Valley',
        description: 'Heaven on Earth with stunning views of Rakaposhi and Ultar Sar peaks. Famous for hospitality, apricot blossoms, and ancient forts.',
        imageUrl: 'https://images.unsplash.com/photo-1599240636297-1eed2ae72cc3?w=800',
        rating: 4.9,
        location: 'Gilgit-Baltistan, Pakistan',
        price: 24999,
        duration: '5 Days 4 Nights',
        bestSeason: 'April to October',
        highlights: ['Baltit Fort', 'Attabad Lake', 'Passu Cones', 'Khunjerab Pass', 'Local Culture'],
      ),
      Destination(
        id: '2',
        name: 'Skardu & Shangrila',
        description: 'Gateway to the world\'s highest peaks including K2. Home to breathtaking lakes and adventure activities.',
        imageUrl: 'https://images.unsplash.com/photo-1587477704623-53a0c4456e7d?w=800',
        rating: 4.8,
        location: 'Skardu, Gilgit-Baltistan',
        price: 29999,
        duration: '7 Days 6 Nights',
        bestSeason: 'May to September',
        highlights: ['Shangrila Resort', 'Upper Kachura Lake', 'K2 Base Camp', 'Deosai Plains', 'Satpara Lake'],
      ),
      Destination(
        id: '3',
        name: 'Fairy Meadows',
        description: 'Magical grassland at the base of Nanga Parbat, the killer mountain. Perfect for trekking and camping under stars.',
        imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
        rating: 4.7,
        location: 'Diamer, Gilgit-Baltistan',
        price: 18999,
        duration: '4 Days 3 Nights',
        bestSeason: 'June to September',
        highlights: ['Nanga Parbat View', 'Beyal Camp', 'Jhelum Meadows', 'Star Gazing', 'Trekking'],
      ),
    ];
  }

  // Get transport options
  List<Map<String, dynamic>> getTransportOptions() {
    return [
      {
        'id': '1',
        'type': 'Luxury Bus',
        'name': 'Daewoo Express',
        'price': 3500,
        'image': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600',
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
        'image': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=600',
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
        'image': 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=600',
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
        'image': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=600',
        'features': ['Quick', 'Comfortable', 'Meals', 'Entertainment', 'Priority'],
        'capacity': 'Economy Class',
        'duration': '1 hour',
        'category': 'Premium',
        'vehicleType': 'Airplane',
      },
    ];
  }

  // Add sample data to Firestore
  Future<void> addSampleData() async {
    try {
      // Add destinations
      for (var destination in getDemoDestinations()) {
        await _firestore
            .collection('destinations')
            .doc(destination.id)
            .set(destination.toMap());
      }

      // Add hotels
      for (var hotel in getDemoHotels('1')) { // For Hunza Valley
        await _firestore
            .collection('hotels')
            .doc(hotel.id)
            .set(hotel.toMap());
      }

      print('Sample data added successfully');
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }

  // Check if data exists
  Future<bool> checkDataExists() async {
    try {
      final destinations = await _firestore.collection('destinations').get();
      return destinations.docs.isNotEmpty;
    } catch (e) {
      print('Error checking data: $e');
      return false;
    }
  }
}