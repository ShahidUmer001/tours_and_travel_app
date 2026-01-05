class Destination {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final String location;
  final double price;
  final String duration;
  final String bestSeason;
  final List<String> highlights;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.location,
    required this.price,
    required this.duration,
    required this.bestSeason,
    required this.highlights,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'location': location,
      'price': price,
      'duration': duration,
      'bestSeason': bestSeason,
      'highlights': highlights,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      duration: map['duration'] ?? '',
      bestSeason: map['bestSeason'] ?? '',
      highlights: List<String>.from(map['highlights'] ?? []),
    );
  }
}