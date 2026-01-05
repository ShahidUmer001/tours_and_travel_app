import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String destinationName;
  final String destinationId; // ✅ ADD THIS
  final DateTime bookingDate;
  final int guests;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.destinationName,
    required this.destinationId, // ✅ ADD THIS
    required this.bookingDate,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'destinationName': destinationName,
      'destinationId': destinationId, // ✅ ADD THIS
      'bookingDate': Timestamp.fromDate(bookingDate),
      'guests': guests,
      'totalPrice': totalPrice,
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    late DateTime bookingDate;

    if (map['bookingDate'] is Timestamp) {
      bookingDate = (map['bookingDate'] as Timestamp).toDate();
    } else if (map['bookingDate'] is String) {
      bookingDate = DateTime.parse(map['bookingDate'] as String);
    } else {
      bookingDate = DateTime.now();
    }

    return Booking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      destinationName: map['destinationName'] ?? '',
      destinationId: map['destinationId'] ?? '', // ✅ ADD THIS
      bookingDate: bookingDate,
      guests: map['guests'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'confirmed',
    );
  }
}