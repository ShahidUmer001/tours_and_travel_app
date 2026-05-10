import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/destination_model.dart';
import '../models/hotel_model.dart';
import '../models/itinerary_model.dart';
import '../services/itinerary_service.dart';
import 'payment_screen.dart';

class ItineraryPlanningScreen extends StatefulWidget {
  final Destination destination;

  const ItineraryPlanningScreen({super.key, required this.destination});

  @override
  State<ItineraryPlanningScreen> createState() => _ItineraryPlanningScreenState();
}

class _ItineraryPlanningScreenState extends State<ItineraryPlanningScreen> {
  late Itinerary _itinerary;
  final _notesController = TextEditingController();
  bool _isLoading = true;
  int _expandedDay = -1;

  late List<Hotel> _destinationHotels;

  static const List<Map<String, dynamic>> _vehicleTypes = [
    {'name': 'Car (Sedan)', 'icon': Icons.directions_car, 'price': 10000},
    {'name': 'SUV 4x4', 'icon': Icons.directions_car_filled, 'price': 18000},
    {'name': 'Jeep 4x4', 'icon': Icons.terrain, 'price': 15000},
    {'name': 'Van (Hiace)', 'icon': Icons.airport_shuttle, 'price': 12000},
    {'name': 'Coaster Bus', 'icon': Icons.directions_bus, 'price': 8000},
    {'name': 'Luxury Bus', 'icon': Icons.directions_bus_filled, 'price': 3500},
    {'name': 'Bike', 'icon': Icons.two_wheeler, 'price': 2000},
    {'name': 'Flight', 'icon': Icons.flight, 'price': 25000},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrCreate();
  }

  Future<void> _loadOrCreate() async {
    _destinationHotels = _getHotelsForDestination(widget.destination.id);
    final existing = await ItineraryService.instance
        .getItinerariesForDestination(widget.destination.id);
    if (existing.isNotEmpty) {
      _itinerary = existing.first;
      // Clamp existing days to 1-30
      if (_itinerary.days.length > 30) {
        _itinerary.days = _itinerary.days.sublist(0, 30);
      }
    } else {
      final now = DateTime.now();
      final durationText = widget.destination.duration;
      final match = RegExp(r'(\d+)').firstMatch(durationText);
      final dayCount = (match != null ? int.tryParse(match.group(1)!) ?? 3 : 3).clamp(1, 30);
      _itinerary = Itinerary(
        id: 'itn_${widget.destination.id}_${now.millisecondsSinceEpoch}',
        destinationId: widget.destination.id,
        destinationName: widget.destination.name,
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(Duration(days: 7 + dayCount - 1)),
        days: List.generate(dayCount, (i) => DayPlan(
          dayNumber: i + 1,
          title: i == 0 ? 'Arrival & Check-in' : i == dayCount - 1 ? 'Departure' : 'Day ${i + 1} - Exploration',
        )),
      );
    }
    _notesController.text = _itinerary.travelNotes;
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    _itinerary.travelNotes = _notesController.text;
    _itinerary.totalBudget = _itinerary.days.fold(0, (sum, d) => sum + d.estimatedBudget);
    await ItineraryService.instance.saveItinerary(_itinerary);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Itinerary saved!'),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _itinerary.startDate, end: _itinerary.endDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue[700]!,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final newDayCount = (picked.end.difference(picked.start).inDays + 1).clamp(1, 30);
      setState(() {
        _itinerary.startDate = picked.start;
        _itinerary.endDate = picked.start.add(Duration(days: newDayCount - 1));
        _adjustDays(newDayCount);
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalBudget = _itinerary.days.fold<double>(0, (s, d) => s + d.estimatedBudget);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Plan Itinerary', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _save,
            tooltip: 'Save Itinerary',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Header
            _buildDestinationHeader(),
            const SizedBox(height: 16),

            // Trip Dates
            _buildTripDatesCard(),
            const SizedBox(height: 12),

            // Custom Day Selector
            _buildDaySelector(),
            const SizedBox(height: 16),

            // Budget Summary
            _buildBudgetSummary(totalBudget),
            const SizedBox(height: 20),

            // Day-wise Plans
            Text('Day-wise Plan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._itinerary.days.asMap().entries.map((e) => _buildDayCard(e.key, e.value)),
            const SizedBox(height: 20),

            // Travel Notes
            _buildTravelNotes(),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text('Save Itinerary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Book Now Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green[700]!, Colors.green[500]!]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final total = _itinerary.days.fold<double>(0, (s, d) => s + d.estimatedBudget);
                    if (total <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(children: [Icon(Icons.warning_amber, color: Colors.white), SizedBox(width: 8), Text('Please add budget for at least one day')]),
                          backgroundColor: Colors.orange[700],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    _save();
                    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    final start = _itinerary.startDate;
                    final end = _itinerary.endDate;
                    final days = end.difference(start).inDays + 1;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          bookingType: 'itinerary',
                          bookingData: {
                            'totalAmount': total,
                            'destinationName': widget.destination.name,
                            'destinationImage': widget.destination.imageUrl,
                            'location': widget.destination.location,
                            'startDate': '${start.day} ${months[start.month - 1]} ${start.year}',
                            'endDate': '${end.day} ${months[end.month - 1]} ${end.year}',
                            'totalDays': days,
                            'dayPlans': _itinerary.days.length,
                            'hotels': _itinerary.days.where((d) => d.hotelName.isNotEmpty).map((d) => d.hotelName).toSet().join(', '),
                            'transport': _itinerary.days.where((d) => d.transportType.isNotEmpty).map((d) => d.transportType).toSet().join(', '),
                          },
                          tourData: {
                            'tourName': '${widget.destination.name} Itinerary',
                            'destination': widget.destination.location,
                            'duration': '$days Days',
                            'price': total,
                            'imageUrl': widget.destination.imageUrl,
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: Text(
                    'Book Now - Rs. ${_itinerary.days.fold<double>(0, (s, d) => s + d.estimatedBudget).toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _adjustDays(int count) {
    final newDayCount = count.clamp(1, 30);
    while (_itinerary.days.length < newDayCount) {
      final n = _itinerary.days.length + 1;
      _itinerary.days.add(DayPlan(
        dayNumber: n,
        title: n == 1 ? 'Arrival & Check-in' : n == newDayCount ? 'Departure' : 'Day $n - Exploration',
      ));
    }
    if (_itinerary.days.length > newDayCount) {
      _itinerary.days = _itinerary.days.sublist(0, newDayCount);
    }
    for (int i = 0; i < _itinerary.days.length; i++) {
      _itinerary.days[i].dayNumber = i + 1;
    }
    _itinerary.endDate = _itinerary.startDate.add(Duration(days: newDayCount - 1));
  }

  Widget _buildDaySelector() {
    final currentDays = _itinerary.days.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.date_range_rounded, color: Colors.purple[700], size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Duration', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  Text('$currentDays ${currentDays == 1 ? 'Day' : 'Days'}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.purple[800])),
                ],
              ),
              const Spacer(),
              Text('Max 30', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 14),
          // Quick select buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [2, 3, 5, 7, 10, 14, 15, 20, 25, 30].map((d) {
              final isSelected = currentDays == d;
              return GestureDetector(
                onTap: () => setState(() => _adjustDays(d)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(colors: [Colors.purple[600]!, Colors.purple[400]!]) : null,
                    color: isSelected ? null : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text('$d Days', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey[700])),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Custom slider
          Row(
            children: [
              Text('Custom:', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
              Expanded(
                child: Slider(
                  value: currentDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: Colors.purple[600],
                  label: '$currentDays Days',
                  onChanged: (v) => setState(() => _adjustDays(v.round())),
                ),
              ),
              Container(
                width: 44,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(8)),
                child: Text('$currentDays', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.purple[800])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[500]!]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.destination.imageUrl.startsWith('assets/')
                ? Image.asset(widget.destination.imageUrl, width: 70, height: 70, fit: BoxFit.cover)
                : Container(width: 70, height: 70, color: Colors.white24, child: const Icon(Icons.landscape, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.destination.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(widget.destination.location, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(widget.destination.duration, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDatesCard() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final start = _itinerary.startDate;
    final end = _itinerary.endDate;
    final days = end.difference(start).inDays + 1;

    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.calendar_month_rounded, color: Colors.blue[700], size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Dates', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(
                    '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text('$days days', style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue[700], fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.edit_calendar_rounded, color: Colors.blue[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.account_balance_wallet_rounded, color: Colors.green[700], size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated Total Budget', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
              Text('Rs. ${total.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.green[800])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(int index, DayPlan day) {
    final isExpanded = _expandedDay == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpanded ? Colors.blue[300]! : Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Day Header - Tap to expand
          InkWell(
            onTap: () => setState(() => _expandedDay = isExpanded ? -1 : index),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[400]!]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text('${day.dayNumber}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(day.title.isEmpty ? 'Day ${day.dayNumber}' : day.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                        if (day.estimatedBudget > 0)
                          Text('Rs. ${day.estimatedBudget.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),

                  // Day Title
                  _fieldTile(Icons.title_rounded, 'Day Title', day.title, (v) => setState(() => day.title = v)),
                  const SizedBox(height: 12),

                  // Hotel Selector
                  _hotelSelector(day),
                  const SizedBox(height: 12),

                  // Transport Selector
                  _transportSelector(day),
                  const SizedBox(height: 8),

                  // Transport Schedule - Date & Time Picker
                  _transportSchedulePicker(day),
                  const SizedBox(height: 12),

                  // Activities
                  _activitiesSection(day),
                  const SizedBox(height: 12),

                  // Budget
                  _budgetField(day),
                  const SizedBox(height: 12),

                  // Notes
                  _fieldTile(Icons.sticky_note_2_outlined, 'Day Notes', day.notes, (v) => setState(() => day.notes = v), maxLines: 3),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldTile(IconData icon, String label, String value, ValueChanged<String> onChanged, {int maxLines = 1}) {
    return TextField(
      controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.blue[600]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue[400]!, width: 2)),
      ),
    );
  }

  Widget _activitiesSection(DayPlan day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_activity_rounded, size: 20, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text('Activities', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() => day.activities.add(''));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text('Add', style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (day.activities.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text('No activities added yet', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400])),
          ),
        ...day.activities.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: e.value)..selection = TextSelection.collapsed(offset: e.value.length),
                    onChanged: (v) => setState(() => day.activities[e.key] = v),
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Activity ${e.key + 1}',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.circle, size: 8),
                      prefixIconConstraints: const BoxConstraints(minWidth: 28),
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue[400]!, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => day.activities.removeAt(e.key)),
                  child: Icon(Icons.remove_circle_outline, size: 20, color: Colors.red[400]),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _budgetField(DayPlan day) {
    return TextField(
      controller: TextEditingController(text: day.estimatedBudget > 0 ? day.estimatedBudget.toStringAsFixed(0) : '')
        ..selection = TextSelection.collapsed(offset: day.estimatedBudget > 0 ? day.estimatedBudget.toStringAsFixed(0).length : 0),
      onChanged: (v) => setState(() => day.estimatedBudget = double.tryParse(v) ?? 0),
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Estimated Budget (Rs.)',
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        prefixIcon: Icon(Icons.monetization_on_outlined, size: 20, color: Colors.green[600]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green[400]!, width: 2)),
      ),
    );
  }

  Widget _buildTravelNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Travel Notes', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          maxLines: 5,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Write your travel notes, reminders, packing list...',
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Icon(Icons.edit_note_rounded, color: Colors.blue[600]),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue[400]!, width: 2)),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SMART SELECTORS
  // ============================================================

  Widget _hotelSelector(DayPlan day) {
    final selectedHotel = _destinationHotels.where((h) => h.name == day.hotelName).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showHotelPicker(day),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Hotel Name',
              labelStyle: GoogleFonts.poppins(fontSize: 13),
              prefixIcon: Icon(Icons.hotel_rounded, size: 20, color: Colors.blue[600]),
              suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Text(
              day.hotelName.isEmpty ? 'Tap to select hotel' : day.hotelName,
              style: GoogleFonts.poppins(fontSize: 14, color: day.hotelName.isEmpty ? Colors.grey[400] : Colors.black87),
            ),
          ),
        ),
        if (selectedHotel != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text('${selectedHotel.rating}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(6)),
                      child: Text(selectedHotel.category, style: GoogleFonts.poppins(fontSize: 11, color: Colors.blue[800], fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(child: Text(selectedHotel.location, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 14, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text('Rs. ${selectedHotel.pricePerNight.toStringAsFixed(0)} / night', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green[800])),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: selectedHotel.amenities.take(4).map((a) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Text(a, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[700])),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showHotelPicker(DayPlan day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Select Hotel', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _destinationHotels.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (ctx, i) {
                  final hotel = _destinationHotels[i];
                  final isSelected = day.hotelName == hotel.name;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: isSelected ? BorderSide(color: Colors.blue[700]!, width: 2) : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          day.hotelName = hotel.name;
                          day.hotelNotes = '${hotel.category} | ${hotel.location} | Rs. ${hotel.pricePerNight.toStringAsFixed(0)}/night';
                        });
                        Navigator.pop(ctx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(hotel.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.hotel))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hotel.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                                  Text(hotel.location, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                      Text(' ${hotel.rating}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      Text('Rs. ${hotel.pricePerNight.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green[700])),
                                      Text('/night', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) Icon(Icons.check_circle, color: Colors.blue[700]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transportSelector(DayPlan day) {
    return GestureDetector(
      onTap: () => _showTransportPicker(day),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Transport Type',
          labelStyle: GoogleFonts.poppins(fontSize: 13),
          prefixIcon: Icon(Icons.directions_car_rounded, size: 20, color: Colors.blue[600]),
          suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Text(
          day.transportType.isEmpty ? 'Tap to select vehicle' : day.transportType,
          style: GoogleFonts.poppins(fontSize: 14, color: day.transportType.isEmpty ? Colors.grey[400] : Colors.black87),
        ),
      ),
    );
  }

  void _showTransportPicker(DayPlan day) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Select Vehicle', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const Divider(),
          ...(_vehicleTypes.map((v) {
            final isSelected = day.transportType == v['name'];
            return ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(v['icon'] as IconData, color: isSelected ? Colors.blue[700] : Colors.grey[600]),
              ),
              title: Text(v['name'] as String, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('~ Rs. ${v['price']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[700])),
              trailing: isSelected ? Icon(Icons.check_circle, color: Colors.blue[700]) : null,
              onTap: () {
                setState(() => day.transportType = v['name'] as String);
                Navigator.pop(ctx);
              },
            );
          })),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _transportSchedulePicker(DayPlan day) {
    return GestureDetector(
      onTap: () => _pickTransportSchedule(day),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Transport Schedule',
          labelStyle: GoogleFonts.poppins(fontSize: 13),
          prefixIcon: Icon(Icons.schedule_rounded, size: 20, color: Colors.blue[600]),
          suffixIcon: Icon(Icons.edit_calendar_rounded, size: 20, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Text(
          day.transportDetails.isEmpty ? 'Tap to set date & time' : day.transportDetails,
          style: GoogleFonts.poppins(fontSize: 14, color: day.transportDetails.isEmpty ? Colors.grey[400] : Colors.black87),
        ),
      ),
    );
  }

  Future<void> _pickTransportSchedule(DayPlan day) async {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final date = await showDatePicker(
      context: context,
      initialDate: _itinerary.startDate.add(Duration(days: day.dayNumber - 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Colors.blue[700]!, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 8, minute: 0),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Colors.blue[700]!, onPrimary: Colors.white)),
          child: child!,
        ),
      );
      if (time != null) {
        final period = time.hour >= 12 ? 'PM' : 'AM';
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final minute = time.minute.toString().padLeft(2, '0');
        setState(() {
          day.transportDetails = '${date.day} ${months[date.month - 1]} ${date.year} at $hour:$minute $period';
        });
      }
    }
  }

  List<Hotel> _getHotelsForDestination(String destinationId) {
    final allHotels = [
      Hotel(id: 'hunza1', name: 'Serena Hotel Hunza', destinationId: '1', rating: 4.8, imageUrl: 'assets/images/hotels/hunza_hotel_1.jpg', location: 'Karimabad, Hunza', pricePerNight: 25000, description: 'Luxury hotel with breathtaking views', amenities: ['Free WiFi', 'Fine Dining', 'Mountain View', 'Spa', 'Heated Pool'], category: '5 Star Luxury'),
      Hotel(id: 'hunza2', name: "Eagle's Nest Hotel", destinationId: '1', rating: 4.6, imageUrl: 'assets/images/hotels/hunza_hotel_2.jpg', location: 'Duikar, Hunza', pricePerNight: 15000, description: 'Panoramic views of entire valley', amenities: ['Panoramic View', 'Restaurant', 'Free Parking', 'Tour Desk'], category: '4 Star Premium'),
      Hotel(id: 'hunza3', name: 'Hunza Embassy Hotel', destinationId: '1', rating: 4.3, imageUrl: 'assets/images/hotels/hunza_hotel_3.jpg', location: 'Karimabad, Hunza', pricePerNight: 12000, description: 'Comfortable hotel in central Karimabad', amenities: ['Free WiFi', 'Restaurant', 'Mountain View', 'Hot Water'], category: '3 Star Standard'),
      Hotel(id: 'skardu1', name: 'Shangrila Resort Skardu', destinationId: '2', rating: 4.7, imageUrl: 'assets/images/hotels/skardu_hotel_1.jpg', location: 'Upper Kachura, Skardu', pricePerNight: 22000, description: 'Iconic luxury resort with lake view', amenities: ['Lake View', 'Swimming Pool', 'Spa', 'Boating', 'Fine Dining'], category: '5 Star Luxury'),
      Hotel(id: 'skardu2', name: 'PTDC Motel Skardu', destinationId: '2', rating: 4.2, imageUrl: 'assets/images/hotels/skardu_hotel_2.jpg', location: 'Skardu City', pricePerNight: 11000, description: 'Comfortable government hotel', amenities: ['Restaurant', 'Parking', 'Tour Desk', '24/7 Service'], category: '3 Star Standard'),
      Hotel(id: 'skardu3', name: 'Baltoro Hotel Skardu', destinationId: '2', rating: 4.1, imageUrl: 'assets/images/hotels/skardu_hotel_3.jpg', location: 'Skardu Road', pricePerNight: 13000, description: 'Modern hotel for tourists and mountaineers', amenities: ['Free WiFi', 'Restaurant', 'Gear Storage', 'Hot Water'], category: '3 Star Standard'),
      Hotel(id: 'swat1', name: 'Swat Serena Hotel', destinationId: '3', rating: 4.6, imageUrl: 'assets/images/hotels/swat_hotel_1.jpg', location: 'Mingora, Swat', pricePerNight: 20000, description: 'Luxury 5-star hotel in Swat Valley', amenities: ['Swimming Pool', 'Spa', 'Fine Dining', 'Conference Hall'], category: '5 Star Luxury'),
      Hotel(id: 'swat2', name: 'Rock City Hotel & Resort', destinationId: '3', rating: 4.3, imageUrl: 'assets/images/hotels/swat_hotel_2.jpg', location: 'Mingora, Swat', pricePerNight: 14000, description: 'Modern hotel with excellent facilities', amenities: ['Free WiFi', 'Restaurant', 'Parking', 'Room Service'], category: '4 Star Premium'),
      Hotel(id: 'swat3', name: 'Malam Jabba Resort', destinationId: '3', rating: 4.1, imageUrl: 'assets/images/hotels/swat_hotel_3.jpg', location: 'Malam Jabba, Swat', pricePerNight: 11000, description: 'Picturesque resort with valley views', amenities: ['Ski Access', 'Mountain View', 'Restaurant', 'Heating'], category: '3 Star Standard'),
      Hotel(id: 'swat4', name: 'Swat View Hotel', destinationId: '3', rating: 4.0, imageUrl: 'assets/images/hotels/swat_hotel_4.jpg', location: 'Mingora, Swat', pricePerNight: 8500, description: 'Comfortable hotel with valley views', amenities: ['Valley View', 'Restaurant', 'Free Parking'], category: '3 Star Standard'),
      Hotel(id: 'naran1', name: 'Pearl Continental Bhurban', destinationId: '4', rating: 4.7, imageUrl: 'assets/images/hotels/naran_hotel_1.jpg', location: 'Bhurban, Near Naran', pricePerNight: 28000, description: 'Luxury 5-star mountain resort', amenities: ['Mountain View', 'Golf Course', 'Spa', 'Swimming Pool'], category: '5 Star Luxury'),
      Hotel(id: 'naran2', name: 'Hotel One Naran', destinationId: '4', rating: 4.4, imageUrl: 'assets/images/hotels/naran_hotel_2.jpg', location: 'Naran City Center', pricePerNight: 16000, description: 'Premium hotel with modern amenities', amenities: ['Free WiFi', 'Restaurant', 'Heating', 'Parking'], category: '4 Star Premium'),
      Hotel(id: 'naran3', name: 'Kaghan Continental Hotel', destinationId: '4', rating: 4.2, imageUrl: 'assets/images/hotels/naran_hotel_3.jpg', location: 'Kaghan City Center', pricePerNight: 12000, description: 'Comfortable hotel in Kaghan valley', amenities: ['Valley View', 'Restaurant', 'Hot Water', 'Parking'], category: '3 Star Standard'),
      Hotel(id: 'naran4', name: 'Naran Park Hotel', destinationId: '4', rating: 4.1, imageUrl: 'assets/images/hotels/naran_hotel_4.jpg', location: 'Naran Valley', pricePerNight: 9500, description: 'Cozy hotel surrounded by nature', amenities: ['Garden', 'Restaurant', 'Parking', 'Bonfire'], category: '3 Star Standard'),
      Hotel(id: 'naran5', name: 'Saif-ul-Malook Hotel', destinationId: '4', rating: 3.8, imageUrl: 'assets/images/hotels/naran_hotel_5.jpg', location: 'Lake Road, Naran', pricePerNight: 8000, description: 'Budget hotel near Lake Saif-ul-Malook', amenities: ['Lake Access', 'Restaurant', 'Parking'], category: '2 Star Budget'),
      Hotel(id: 'fairy1', name: 'Fairy Meadows Resort', destinationId: '5', rating: 4.5, imageUrl: 'assets/images/hotels/fairy_hotel_1.jpg', location: 'Fairy Meadows', pricePerNight: 18000, description: 'Luxury camping resort with Nanga Parbat views', amenities: ['Nanga Parbat View', 'Luxury Tents', 'Bonfire', 'Guide Services'], category: '4 Star Premium'),
      Hotel(id: 'fairy2', name: 'Beyal Camp', destinationId: '5', rating: 4.4, imageUrl: 'assets/images/hotels/fairy_hotel_2.jpg', location: 'Beyal Camp, Fairy Meadows', pricePerNight: 15000, description: 'Adventure camp with luxury tents', amenities: ['Luxury Tents', 'Mountain View', 'Bonfire', 'Trekking Guides'], category: '4 Star Premium'),
      Hotel(id: 'fairy3', name: 'Raikot Serai Hotel', destinationId: '5', rating: 4.2, imageUrl: 'assets/images/hotels/fairy_hotel_3.jpg', location: 'Raikot Bridge', pricePerNight: 12000, description: 'Base camp hotel for Fairy Meadows trek', amenities: ['Trek Planning', 'Restaurant', 'Parking', 'Guide Services'], category: '3 Star Standard'),
    ];
    return allHotels.where((h) => h.destinationId == destinationId).toList();
  }
}
