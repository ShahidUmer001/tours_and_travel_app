import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hotel_model.dart';
import '../models/car_model.dart';

/// Service to manage user-submitted hotels and cars.
/// Stores listings locally via SharedPreferences so any user
/// can register their own hotel/car directly from the app.
class UserListingsService extends ChangeNotifier {
  UserListingsService._();
  static final UserListingsService instance = UserListingsService._();

  static const _kHotelsKey = 'user_hotels_v1';
  static const _kCarsKey = 'user_cars_v1';

  List<UserHotel> _hotels = [];
  List<UserCar> _cars = [];

  List<UserHotel> get hotels => List.unmodifiable(_hotels);
  List<UserCar> get cars => List.unmodifiable(_cars);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final hotelsRaw = prefs.getString(_kHotelsKey);
    if (hotelsRaw != null && hotelsRaw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(hotelsRaw) as List<dynamic>;
        _hotels = list
            .map((e) => UserHotel.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        debugPrint('Failed to parse user hotels: $e');
      }
    }

    final carsRaw = prefs.getString(_kCarsKey);
    if (carsRaw != null && carsRaw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(carsRaw) as List<dynamic>;
        _cars = list
            .map((e) => UserCar.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        debugPrint('Failed to parse user cars: $e');
      }
    }

    notifyListeners();
  }

  // ============= HOTELS =============
  List<UserHotel> hotelsByUser(String? email) {
    if (email == null) return [];
    return _hotels.where((h) => h.ownerEmail == email).toList();
  }

  Future<void> addHotel(UserHotel hotel) async {
    _hotels.add(hotel);
    await _persistHotels();
    notifyListeners();
  }

  Future<void> updateHotel(UserHotel hotel) async {
    final idx = _hotels.indexWhere((h) => h.id == hotel.id);
    if (idx >= 0) {
      _hotels[idx] = hotel;
      await _persistHotels();
      notifyListeners();
    }
  }

  Future<void> removeHotel(String id) async {
    _hotels.removeWhere((h) => h.id == id);
    await _persistHotels();
    notifyListeners();
  }

  Future<void> _persistHotels() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_hotels.map((h) => h.toMap()).toList());
    await prefs.setString(_kHotelsKey, encoded);
  }

  // ============= CARS =============
  List<UserCar> carsByUser(String? email) {
    if (email == null) return [];
    return _cars.where((c) => c.ownerEmail == email).toList();
  }

  Future<void> addCar(UserCar car) async {
    _cars.add(car);
    await _persistCars();
    notifyListeners();
  }

  Future<void> updateCar(UserCar car) async {
    final idx = _cars.indexWhere((c) => c.id == car.id);
    if (idx >= 0) {
      _cars[idx] = car;
      await _persistCars();
      notifyListeners();
    }
  }

  Future<void> removeCar(String id) async {
    _cars.removeWhere((c) => c.id == id);
    await _persistCars();
    notifyListeners();
  }

  Future<void> _persistCars() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_cars.map((c) => c.toMap()).toList());
    await prefs.setString(_kCarsKey, encoded);
  }
}

// ==================== UserHotel Model ====================
class UserHotel {
  final String id;
  final String ownerEmail;
  final String ownerName;
  final String name;
  final String location;
  final String city;
  final double pricePerNight;
  final double rating;
  final String description;
  final List<String> amenities;
  final String category;
  final String contactPhone;
  final String imagePath; // local file path or empty
  final DateTime createdAt;

  UserHotel({
    required this.id,
    required this.ownerEmail,
    required this.ownerName,
    required this.name,
    required this.location,
    required this.city,
    required this.pricePerNight,
    required this.rating,
    required this.description,
    required this.amenities,
    required this.category,
    required this.contactPhone,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerEmail': ownerEmail,
        'ownerName': ownerName,
        'name': name,
        'location': location,
        'city': city,
        'pricePerNight': pricePerNight,
        'rating': rating,
        'description': description,
        'amenities': amenities,
        'category': category,
        'contactPhone': contactPhone,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserHotel.fromMap(Map<String, dynamic> map) => UserHotel(
        id: map['id'] ?? '',
        ownerEmail: map['ownerEmail'] ?? '',
        ownerName: map['ownerName'] ?? '',
        name: map['name'] ?? '',
        location: map['location'] ?? '',
        city: map['city'] ?? '',
        pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
        rating: (map['rating'] ?? 0).toDouble(),
        description: map['description'] ?? '',
        amenities: List<String>.from(map['amenities'] ?? []),
        category: map['category'] ?? 'Standard',
        contactPhone: map['contactPhone'] ?? '',
        imagePath: map['imagePath'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );

  /// Convert to the shared Hotel model used across the app.
  Hotel toHotel() => Hotel(
        id: id,
        name: name,
        destinationId: city,
        rating: rating,
        imageUrl: imagePath,
        location: location,
        pricePerNight: pricePerNight,
        description: description,
        amenities: amenities,
        category: category,
      );
}

// ==================== UserCar Model ====================
class UserCar {
  final String id;
  final String ownerEmail;
  final String ownerName;
  final String name;
  final String type;
  final double pricePerKm;
  final int capacity;
  final List<String> features;
  final double rating;
  final String transmission;
  final String fuelType;
  final bool ac;
  final String contactPhone;
  final String imagePath;
  final DateTime createdAt;

  UserCar({
    required this.id,
    required this.ownerEmail,
    required this.ownerName,
    required this.name,
    required this.type,
    required this.pricePerKm,
    required this.capacity,
    required this.features,
    required this.rating,
    required this.transmission,
    required this.fuelType,
    required this.ac,
    required this.contactPhone,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerEmail': ownerEmail,
        'ownerName': ownerName,
        'name': name,
        'type': type,
        'pricePerKm': pricePerKm,
        'capacity': capacity,
        'features': features,
        'rating': rating,
        'transmission': transmission,
        'fuelType': fuelType,
        'ac': ac,
        'contactPhone': contactPhone,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserCar.fromMap(Map<String, dynamic> map) => UserCar(
        id: map['id'] ?? '',
        ownerEmail: map['ownerEmail'] ?? '',
        ownerName: map['ownerName'] ?? '',
        name: map['name'] ?? '',
        type: map['type'] ?? '',
        pricePerKm: (map['pricePerKm'] ?? 0).toDouble(),
        capacity: map['capacity'] ?? 0,
        features: List<String>.from(map['features'] ?? []),
        rating: (map['rating'] ?? 0).toDouble(),
        transmission: map['transmission'] ?? 'Manual',
        fuelType: map['fuelType'] ?? 'Petrol',
        ac: map['ac'] ?? false,
        contactPhone: map['contactPhone'] ?? '',
        imagePath: map['imagePath'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );

  Car toCar() => Car(
        id: id,
        name: name,
        type: type,
        imageUrl: imagePath,
        pricePerKm: pricePerKm,
        capacity: capacity,
        features: features,
        rating: rating,
        transmission: transmission,
        fuelType: fuelType,
        ac: ac,
      );
}
