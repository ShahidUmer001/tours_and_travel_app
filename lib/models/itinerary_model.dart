class DayPlan {
  int dayNumber;
  String title;
  String hotelName;
  String hotelNotes;
  String transportType;
  String transportDetails;
  List<String> activities;
  double estimatedBudget;
  String notes;

  DayPlan({
    required this.dayNumber,
    this.title = '',
    this.hotelName = '',
    this.hotelNotes = '',
    this.transportType = '',
    this.transportDetails = '',
    List<String>? activities,
    this.estimatedBudget = 0,
    this.notes = '',
  }) : activities = activities ?? [];

  Map<String, dynamic> toMap() => {
        'dayNumber': dayNumber,
        'title': title,
        'hotelName': hotelName,
        'hotelNotes': hotelNotes,
        'transportType': transportType,
        'transportDetails': transportDetails,
        'activities': activities,
        'estimatedBudget': estimatedBudget,
        'notes': notes,
      };

  factory DayPlan.fromMap(Map<String, dynamic> map) => DayPlan(
        dayNumber: map['dayNumber'] ?? 1,
        title: map['title'] ?? '',
        hotelName: map['hotelName'] ?? '',
        hotelNotes: map['hotelNotes'] ?? '',
        transportType: map['transportType'] ?? '',
        transportDetails: map['transportDetails'] ?? '',
        activities: List<String>.from(map['activities'] ?? []),
        estimatedBudget: (map['estimatedBudget'] ?? 0).toDouble(),
        notes: map['notes'] ?? '',
      );
}

class Itinerary {
  final String id;
  final String destinationId;
  final String destinationName;
  DateTime startDate;
  DateTime endDate;
  List<DayPlan> days;
  double totalBudget;
  String travelNotes;
  final DateTime createdAt;

  Itinerary({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.startDate,
    required this.endDate,
    List<DayPlan>? days,
    this.totalBudget = 0,
    this.travelNotes = '',
    DateTime? createdAt,
  })  : days = days ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'destinationId': destinationId,
        'destinationName': destinationName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'days': days.map((d) => d.toMap()).toList(),
        'totalBudget': totalBudget,
        'travelNotes': travelNotes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Itinerary.fromMap(Map<String, dynamic> map) => Itinerary(
        id: map['id'] ?? '',
        destinationId: map['destinationId'] ?? '',
        destinationName: map['destinationName'] ?? '',
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        days: (map['days'] as List?)?.map((d) => DayPlan.fromMap(d)).toList() ?? [],
        totalBudget: (map['totalBudget'] ?? 0).toDouble(),
        travelNotes: map['travelNotes'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );
}
