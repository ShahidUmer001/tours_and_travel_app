class Hotel {
  final String id;
  final String name;
  final String destinationId; // ✅ YEH FIELD ADD KARO
  final double rating;
  final String imageUrl;
  final String location;
  final double pricePerNight;
  final String description;
  final List<String> amenities;
  final String category;

  Hotel({
    required this.id,
    required this.name,
    required this.destinationId, // ✅ YEH FIELD ADD KARO
    required this.rating,
    required this.imageUrl,
    required this.location,
    required this.pricePerNight,
    required this.description,
    required this.amenities,
    required this.category,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'destinationId': destinationId, // ✅ YEH FIELD ADD KARO
      'rating': rating,
      'imageUrl': imageUrl,
      'location': location,
      'pricePerNight': pricePerNight,
      'description': description,
      'amenities': amenities,
      'category': category,
    };
  }

  // Create from Map from Firebase
  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      destinationId: map['destinationId'] ?? '', // ✅ YEH FIELD ADD KARO
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      category: map['category'] ?? '',
    );
  }

  // Helper methods
  String getPriceInfo() {
    return 'Rs. ${pricePerNight.toStringAsFixed(0)}/night';
  }

  String getRatingInfo() {
    return '$rating/5';
  }

  String getAmenitiesSummary() {
    return amenities.take(3).join(', ');
  }

  bool hasAmenity(String amenity) {
    return amenities.contains(amenity);
  }
}