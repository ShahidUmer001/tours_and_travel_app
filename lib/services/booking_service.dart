// services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's bookings - YAHAN FIX KARENA
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data() as Map<String, dynamic>); // ✅ Fix yahan hai
      }).toList();
    });
  }

  // Create new booking - YE BHI THODA UPDATE KAREIN
  Future<void> createBooking(Booking booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      print('Error creating booking: $e');
      throw e;
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({'status': status});
    } catch (e) {
      print('Error updating booking status: $e');
      throw e;
    }
  }
}