class CarBooking {
  final String id;
  final String userId;
  final String carId;
  final String carName;
  final String carType;
  final String carImageUrl;
  final double carPricePerKm;
  final String pickupCity;
  final String dropoffCity;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final String pickupTime; // String format: "HH:mm"
  final int totalDays;
  final double totalDistance;
  final double totalAmount;
  final String status;
  final DateTime bookingDate;

  CarBooking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carName,
    required this.carType,
    required this.carImageUrl,
    required this.carPricePerKm,
    required this.pickupCity,
    required this.dropoffCity,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupTime,
    required this.totalDays,
    required this.totalDistance,
    required this.totalAmount,
    required this.status,
    required this.bookingDate,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'carName': carName,
      'carType': carType,
      'carImageUrl': carImageUrl,
      'carPricePerKm': carPricePerKm,
      'pickupCity': pickupCity,
      'dropoffCity': dropoffCity,
      'pickupDate': pickupDate.toIso8601String(),
      'dropoffDate': dropoffDate.toIso8601String(),
      'pickupTime': pickupTime,
      'totalDays': totalDays,
      'totalDistance': totalDistance,
      'totalAmount': totalAmount,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
    };
  }

  // Create from Map from Firebase
  factory CarBooking.fromMap(Map<String, dynamic> map) {
    return CarBooking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      carId: map['carId'] ?? '',
      carName: map['carName'] ?? '',
      carType: map['carType'] ?? '',
      carImageUrl: map['carImageUrl'] ?? '',
      carPricePerKm: (map['carPricePerKm'] ?? 0).toDouble(),
      pickupCity: map['pickupCity'] ?? '',
      dropoffCity: map['dropoffCity'] ?? '',
      pickupDate: DateTime.parse(map['pickupDate']),
      dropoffDate: DateTime.parse(map['dropoffDate']),
      pickupTime: map['pickupTime'] ?? '00:00',
      totalDays: map['totalDays'] ?? 1,
      totalDistance: (map['totalDistance'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'confirmed',
      bookingDate: DateTime.parse(map['bookingDate']),
    );
  }

  // Helper method to display booking summary
  String getBookingSummary() {
    return '$carName • $pickupCity to $dropoffCity • $totalDays days';
  }

  // Helper method to format date
  String getFormattedPickupDate() {
    return '${pickupDate.day}/${pickupDate.month}/${pickupDate.year}';
  }

  // Helper method to format amount
  String getFormattedAmount() {
    return 'Rs. ${totalAmount.toStringAsFixed(0)}';
  }
}