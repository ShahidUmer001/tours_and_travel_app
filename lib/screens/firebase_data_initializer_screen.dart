import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataInitializerScreen extends StatelessWidget {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> _addSampleHotels() async {
    try {
      // Swat Valley Hotels
      await _firestore.collection('hotels').doc('10').set({
        'name': 'Swat Serena Hotel',
        'destinationId': '4',
        'rating': 4.6,
        'imageUrl': 'https://images.unsplash.com/photo-1564501049412-61c2a3083791',
        'location': 'Mingora, Swat, KPK',
        'pricePerNight': 20000,
        'description': 'Luxury 5-star hotel in the heart of Swat Valley...',
        'amenities': ['Swimming Pool', 'Spa', 'Fine Dining', 'Conference Hall', 'Kids Club'],
        'category': '5 Star Luxury',
      });

      await _firestore.collection('hotels').doc('11').set({
        'name': 'Rock City Hotel & Resort',
        'destinationId': '4',
        'rating': 4.3,
        'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb',
        'location': 'Mingora, Swat, KPK',
        'pricePerNight': 14000,
        'description': 'Modern hotel with excellent facilities...',
        'amenities': ['Free WiFi', 'Restaurant', 'Parking', 'Room Service'],
        'category': '4 Star Premium',
      });

      await _firestore.collection('hotels').doc('12').set({
        'name': 'Malam Jabba Resort',
        'destinationId': '4',
        'rating': 4.1,
        'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa',
        'location': 'Malam Jabba, Swat, KPK',
        'pricePerNight': 11000,
        'description': 'Picturesque resort in Malam Jabba...',
        'amenities': ['Ski Access', 'Mountain View', 'Restaurant'],
        'category': '3 Star Standard',
      });

      print('✅ Hotels added successfully!');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Initialize Firebase Data')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addSampleHotels,
              child: Text('Add Sample Hotels to Firestore'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Check if hotels exist
                final snapshot = await _firestore.collection('hotels').get();
                print('Total hotels: ${snapshot.docs.length}');
              },
              child: Text('Check Existing Hotels'),
            ),
          ],
        ),
      ),
    );
  }
}