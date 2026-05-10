import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/itinerary_model.dart';
import '../main.dart' show firebaseInitialized;
import 'local_auth_service.dart';

class ItineraryService {
  ItineraryService._();
  static final ItineraryService instance = ItineraryService._();

  static const _kItinerariesKey = 'saved_itineraries_v1';

  Future<void> saveItinerary(Itinerary itinerary) async {
    // Save locally
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadAllLocal(prefs);
    all[itinerary.id] = itinerary.toMap();
    await prefs.setString(_kItinerariesKey, jsonEncode(all));

    // Save to Firebase if available
    if (firebaseInitialized) {
      try {
        final uid = LocalAuthService.instance.currentEmail ?? 'anonymous';
        await FirebaseFirestore.instance
            .collection('itineraries')
            .doc(itinerary.id)
            .set({
          ...itinerary.toMap(),
          'userId': uid,
        });
      } catch (_) {}
    }
  }

  Future<Itinerary?> getItinerary(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadAllLocal(prefs);
    if (all.containsKey(id)) {
      return Itinerary.fromMap(Map<String, dynamic>.from(all[id]));
    }
    return null;
  }

  Future<List<Itinerary>> getItinerariesForDestination(String destinationId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadAllLocal(prefs);
    return all.values
        .map((v) => Itinerary.fromMap(Map<String, dynamic>.from(v)))
        .where((i) => i.destinationId == destinationId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteItinerary(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadAllLocal(prefs);
    all.remove(id);
    await prefs.setString(_kItinerariesKey, jsonEncode(all));

    if (firebaseInitialized) {
      try {
        await FirebaseFirestore.instance.collection('itineraries').doc(id).delete();
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>> _loadAllLocal(SharedPreferences prefs) async {
    final raw = prefs.getString(_kItinerariesKey);
    if (raw == null || raw.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }
}
