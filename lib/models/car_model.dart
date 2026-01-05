class Car {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final double pricePerKm;
  final int capacity;
  final List<String> features;
  final double rating;
  final String transmission;
  final String fuelType;
  final bool ac;

  Car({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.pricePerKm,
    required this.capacity,
    required this.features,
    required this.rating,
    required this.transmission,
    required this.fuelType,
    required this.ac,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
      'pricePerKm': pricePerKm,
      'capacity': capacity,
      'features': features,
      'rating': rating,
      'transmission': transmission,
      'fuelType': fuelType,
      'ac': ac,
    };
  }

  // Create from Map from Firebase
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pricePerKm: (map['pricePerKm'] ?? 0).toDouble(),
      capacity: map['capacity'] ?? 0,
      features: List<String>.from(map['features'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      transmission: map['transmission'] ?? '',
      fuelType: map['fuelType'] ?? '',
      ac: map['ac'] ?? false,
    );
  }

  // Helper method to display car info
  String getCarInfo() {
    return '$name • $type • $transmission • $fuelType';
  }

  // Helper method to get capacity info
  String getCapacityInfo() {
    return '$capacity people';
  }

  // Helper method to get price info
  String getPriceInfo() {
    return 'Rs. $pricePerKm/km';
  }
}