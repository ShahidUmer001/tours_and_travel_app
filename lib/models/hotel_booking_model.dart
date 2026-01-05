class HotelBooking {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String hotelImageUrl;
  final String location;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;
  final double totalAmount;
  final String status; // completed, upcoming, cancelled, pending
  final DateTime bookingDate;

  HotelBooking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.hotelImageUrl,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
    required this.totalAmount,
    required this.status,
    required this.bookingDate,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'hotelImageUrl': hotelImageUrl,
      'location': location,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'guests': guests,
      'rooms': rooms,
      'totalAmount': totalAmount,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
    };
  }

  // Create from Map from Firebase
  factory HotelBooking.fromMap(Map<String, dynamic> map) {
    return HotelBooking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      hotelId: map['hotelId'] ?? '',
      hotelName: map['hotelName'] ?? '',
      hotelImageUrl: map['hotelImageUrl'] ?? '',
      location: map['location'] ?? '',
      checkInDate: DateTime.parse(map['checkInDate']),
      checkOutDate: DateTime.parse(map['checkOutDate']),
      guests: map['guests'] ?? 1,
      rooms: map['rooms'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      bookingDate: DateTime.parse(map['bookingDate']),
    );
  }

  // Helper methods
  String getBookingSummary() {
    return '$hotelName • $location • ${_formatDate(checkInDate)} - ${_formatDate(checkOutDate)}';
  }

  String getFormattedAmount() {
    return 'Rs. ${totalAmount.toStringAsFixed(0)}';
  }

  String getFormattedCheckInDate() {
    return _formatDate(checkInDate);
  }

  String getFormattedCheckOutDate() {
    return _formatDate(checkOutDate);
  }

  int getTotalNights() {
    return checkOutDate.difference(checkInDate).inDays;
  }

  String getDurationText() {
    final nights = getTotalNights();
    return '$nights night${nights > 1 ? 's' : ''}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Get status color
  String getStatusText() {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'upcoming':
        return 'Upcoming';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Check if booking can be cancelled
  bool get canBeCancelled {
    return status == 'confirmed' || status == 'upcoming' || status == 'pending';
  }

  // Check if booking is active
  bool get isActive {
    return status == 'confirmed' || status == 'upcoming';
  }

  // Check if booking is completed
  bool get isCompleted {
    return status == 'completed';
  }

  // Check if booking is cancelled
  bool get isCancelled {
    return status == 'cancelled';
  }
}