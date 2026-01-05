// models/tour_model.dart
class TourPackage {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String duration;
  final String bestSeason;
  final double rating;
  final List<String> destinations;
  final List<String> highlights;
  final String category;
  final List<Map<String, dynamic>> itinerary;

  TourPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.duration,
    required this.bestSeason,
    required this.rating,
    required this.destinations,
    required this.highlights,
    required this.category,
    required this.itinerary,
  });
}