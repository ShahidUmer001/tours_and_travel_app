import 'package:flutter/foundation.dart';

class LocalBooking {
  final String id;
  final String type; // 'hotel' | 'tour' | 'car' | 'transport'
  final String title;
  final String subtitle;
  final String? imageUrl;
  final double amount;
  final String paymentMethod;
  final DateTime bookingDate;

  LocalBooking({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.amount,
    required this.paymentMethod,
    required this.bookingDate,
  });
}

/// Singleton store for confirmed bookings.
/// Keeps bookings in memory for the current session so that
/// after a payment confirmation, the booking appears in
/// the Bookings tab immediately.
class LocalBookingStore extends ChangeNotifier {
  LocalBookingStore._();
  static final LocalBookingStore instance = LocalBookingStore._();

  final List<LocalBooking> _bookings = [];

  List<LocalBooking> get bookings => List.unmodifiable(_bookings.reversed);

  List<LocalBooking> byType(String type) =>
      bookings.where((b) => b.type == type).toList();

  void add(LocalBooking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void clear() {
    _bookings.clear();
    notifyListeners();
  }
}
