import 'package:cloud_firestore/cloud_firestore.dart';

class SampleData {
  static Future<void> addSampleDestinations() async {
    final firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> destinations = [
      {
        'id': '1',
        'name': 'Hunza Valley',
        'description': 'Heaven on Earth with stunning views of Rakaposhi and Ultar Sar peaks. Famous for hospitality, apricot blossoms, and ancient forts.',
        'imageUrl': 'https://images.unsplash.com/photo-1599240636297-1eed2ae72cc3',
        'rating': 4.9,
        'location': 'Hunza, Gilgit-Baltistan',
        'price': 24999,
        'duration': '5 Days',
        'bestSeason': 'April to October',
        'highlights': ['Baltit Fort', 'Attabad Lake', 'Passu Cones', 'Khunjerab Pass']
      },
      {
        'id': '2',
        'name': 'Skardu',
        'description': 'Gateway to the world\'s highest peaks including K2. Home to breathtaking lakes and adventure activities.',
        'imageUrl': 'https://images.unsplash.com/photo-1587477704623-53a0c4456e7d',
        'rating': 4.8,
        'location': 'Skardu, Gilgit-Baltistan',
        'price': 29999,
        'duration': '7 Days',
        'bestSeason': 'May to September',
        'highlights': ['Shangrila Resort', 'Upper Kachura Lake', 'K2 Base Camp', 'Deosai Plains']
      },
      {
        'id': '3',
        'name': 'Fairy Meadows',
        'description': 'Magical grassland at the base of Nanga Parbat, the killer mountain. Perfect for trekking and camping.',
        'imageUrl': 'https://images.unsplash.com/photo-1551632811-561732d1e306',
        'rating': 4.7,
        'location': 'Diamer, Gilgit-Baltistan',
        'price': 18999,
        'duration': '4 Days',
        'bestSeason': 'June to September',
        'highlights': ['Nanga Parbat View', 'Beyal Camp', 'Jhelum Meadows', 'Star Gazing']
      },
      {
        'id': '4',
        'name': 'Shigar Valley',
        'description': 'Historic valley with ancient palaces, lush gardens, and traditional Balti culture.',
        'imageUrl': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
        'rating': 4.6,
        'location': 'Shigar, Gilgit-Baltistan',
        'price': 15999,
        'duration': '3 Days',
        'bestSeason': 'April to October',
        'highlights': ['Shigar Fort', 'Amacha Garden', 'Traditional Villages', 'Trekking Routes']
      },
      {
        'id': '5',
        'name': 'Naltar Valley',
        'description': 'Colorful lakes and pine forests, famous for its skiing resort and vibrant landscapes.',
        'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
        'rating': 4.5,
        'location': 'Naltar, Gilgit-Baltistan',
        'price': 12999,
        'duration': '3 Days',
        'bestSeason': 'June to September',
        'highlights': ['Naltar Lakes', 'Ski Resort', 'Pine Forests', 'Wildlife Spotting']
      }
    ];

    for (var destination in destinations) {
      await firestore
          .collection('destinations')
          .doc(destination['id'])
          .set(destination);
    }
    await addSampleHotels();
    await addSampleTransport();
  }

  static Future<void> addSampleHotels() async {
    final firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> hotels = [
      {
        'id': '1',
        'name': 'Serena Hotel Shigar Fort',
        'destinationId': '4',
        'rating': 4.8,
        'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
        'location': 'Shigar Fort, Shigar',
        'pricePerNight': 12000,
        'description': 'Luxury heritage hotel in restored 17th-century fort',
        'amenities': ['Free WiFi', 'Restaurant', 'Garden', 'Heritage Tour', 'Spa']
      },
      {
        'id': '2',
        'name': 'Eagle\'s Nest Hotel',
        'destinationId': '1',
        'rating': 4.5,
        'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
        'location': 'Duikar, Hunza',
        'pricePerNight': 8000,
        'description': 'Panoramic views of Hunza Valley from the highest point',
        'amenities': ['Mountain View', 'Restaurant', 'Free Parking', 'Tour Desk']
      },
      {
        'id': '3',
        'name': 'Shangrila Resort Skardu',
        'destinationId': '2',
        'rating': 4.7,
        'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa',
        'location': 'Upper Kachura, Skardu',
        'pricePerNight': 15000,
        'description': 'Luxury resort with lake view and premium amenities',
        'amenities': ['Lake View', 'Swimming Pool', 'Spa', 'Boating', 'Fine Dining']
      }
    ];

    for (var hotel in hotels) {
      await firestore
          .collection('hotels')
          .doc(hotel['id'])
          .set(hotel);
    }
  }

  static Future<void> addSampleTransport() async {
    final firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> transport = [
      {
        'id': '1',
        'type': 'flight',
        'destinationId': '2',
        'fromLocation': 'Islamabad',
        'toLocation': 'Skardu',
        'departureTime': '2024-06-01T08:00:00',
        'arrivalTime': '2024-06-01T09:30:00',
        'price': 15000,
        'company': 'PIA',
        'vehicleNumber': 'PK-452'
      },
      {
        'id': '2',
        'type': 'bus',
        'destinationId': '1',
        'fromLocation': 'Islamabad',
        'toLocation': 'Hunza',
        'departureTime': '2024-06-01T20:00:00',
        'arrivalTime': '2024-06-02T12:00:00',
        'price': 4000,
        'company': 'NATCO',
        'vehicleNumber': 'NA-789'
      },
      {
        'id': '3',
        'type': 'jeep',
        'destinationId': '3',
        'fromLocation': 'Raikot Bridge',
        'toLocation': 'Fairy Meadows',
        'departureTime': '2024-06-01T10:00:00',
        'arrivalTime': '2024-06-01T14:00:00',
        'price': 3000,
        'company': 'Local Tour',
        'vehicleNumber': 'GB-123'
      }
    ];

    for (var transportOption in transport) {
      await firestore
          .collection('transport')
          .doc(transportOption['id'])
          .set(transportOption);
    }
  }
}