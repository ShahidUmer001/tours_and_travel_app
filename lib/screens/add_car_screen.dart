import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_auth_service.dart';
import '../services/user_listings_service.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';

class AddCarScreen extends StatefulWidget {
  final UserCar? existing;
  const AddCarScreen({super.key, this.existing});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _phoneController = TextEditingController();

  double _rating = 4.0;
  String _type = 'Sedan';
  String _transmission = 'Automatic';
  String _fuelType = 'Petrol';
  bool _ac = true;
  String _imagePath = '';
  bool _saving = false;

  late AnimationController _animController;

  final List<String> _types = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Luxury',
    'Van',
    'Pickup',
    'Coaster',
  ];
  final List<String> _transmissions = ['Automatic', 'Manual'];
  final List<String> _fuels = ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'];

  final List<String> _allFeatures = [
    'Bluetooth',
    'Navigation',
    'Sunroof',
    'Leather Seats',
    'Power Windows',
    'ABS',
    'Airbags',
    'Music System',
    'USB Ports',
    'Rear Camera',
    'Cruise Control',
    'Keyless Entry',
  ];
  final Set<String> _selectedFeatures = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    if (widget.existing != null) {
      final c = widget.existing!;
      _nameController.text = c.name;
      _priceController.text = c.pricePerKm.toStringAsFixed(0);
      _capacityController.text = c.capacity.toString();
      _phoneController.text = c.contactPhone;
      _rating = c.rating;
      _type = c.type;
      _transmission = c.transmission;
      _fuelType = c.fuelType;
      _ac = c.ac;
      _imagePath = c.imagePath;
      _selectedFeatures.addAll(c.features);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      _snack('Could not pick image: $e', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                error ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor:
              error ? AppConstants.errorColor : AppConstants.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _snack('Please fill all required fields', error: true);
      return;
    }
    if (_imagePath.isEmpty) {
      _snack('Please pick a car image', error: true);
      return;
    }

    setState(() => _saving = true);

    final email = LocalAuthService.instance.currentEmail ?? 'guest';
    final ownerName =
        LocalAuthService.instance.currentFullName ?? 'Guest User';

    final car = UserCar(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      ownerEmail: email,
      ownerName: ownerName,
      name: _nameController.text.trim(),
      type: _type,
      pricePerKm: double.tryParse(_priceController.text.trim()) ?? 0,
      capacity: int.tryParse(_capacityController.text.trim()) ?? 4,
      features: _selectedFeatures.toList(),
      rating: _rating,
      transmission: _transmission,
      fuelType: _fuelType,
      ac: _ac,
      contactPhone: _phoneController.text.trim(),
      imagePath: _imagePath,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing != null) {
      await UserListingsService.instance.updateCar(car);
      if (!mounted) return;
      _snack('Car updated successfully!');
    } else {
      await UserListingsService.instance.addCar(car);
      if (!mounted) return;
      _snack('Car registered successfully!');
    }

    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.existing != null ? 'Edit Car' : 'Register Your Car',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroHeader(),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _sectionTitle('Car Details', Icons.directions_car_rounded),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Car Name (e.g. Toyota Corolla 2022)',
                icon: Icons.directions_car_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price/Km (Rs.)',
                      icon: Icons.price_change_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _capacityController,
                      label: 'Seats',
                      icon: Icons.event_seat_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (int.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'Contact Phone',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Type', Icons.category_rounded),
              const SizedBox(height: 10),
              _buildChipRow(_types, _type, (v) => setState(() => _type = v)),
              const SizedBox(height: 20),
              _sectionTitle('Transmission', Icons.settings_rounded),
              const SizedBox(height: 10),
              _buildChipRow(
                _transmissions,
                _transmission,
                (v) => setState(() => _transmission = v),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Fuel Type', Icons.local_gas_station_rounded),
              const SizedBox(height: 10),
              _buildChipRow(
                _fuels,
                _fuelType,
                (v) => setState(() => _fuelType = v),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Air Conditioning', Icons.ac_unit_rounded),
              const SizedBox(height: 10),
              _buildAcToggle(),
              const SizedBox(height: 20),
              _sectionTitle('Rating', Icons.star_rounded),
              const SizedBox(height: 8),
              _buildRatingSelector(),
              const SizedBox(height: 20),
              _sectionTitle('Features', Icons.check_circle_rounded),
              const SizedBox(height: 10),
              _buildFeatures(),
              const SizedBox(height: 28),
              LiquidButton(
                label: _saving
                    ? 'SAVING...'
                    : widget.existing != null
                        ? 'UPDATE CAR'
                        : 'REGISTER CAR',
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _save,
                colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return AnimatedFadeSlide(
      beginOffset: const Offset(0, -0.2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            FloatingAnimation(
              offset: 5,
              child: GlowPulse(
                glowColor: AppConstants.goldAccent,
                maxRadius: 22,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerText(
                    text: 'List Your Car',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Offer your car for city-to-city rentals and earn money',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return ScaleOnTap(
      scaleDown: 0.98,
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            width: 2,
          ),
          boxShadow: AppConstants.cardElevation,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _imagePath.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingAnimation(
                        offset: 4,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to add car photo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textColor,
                        ),
                      ),
                      Text(
                        'Clear side or front view preferred',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppConstants.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_imagePath), fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: const Color(0xFF6366F1), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppConstants.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppConstants.lightTextColor,
          fontSize: 13,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  Widget _buildChipRow(
      List<String> values, String current, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final selected = current == v;
        return ScaleOnTap(
          scaleDown: 0.94,
          onTap: () => onTap(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    )
                  : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? const Color(0xFF6366F1)
                    : AppConstants.borderColor,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              v,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppConstants.textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAcToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppConstants.cardElevation,
      ),
      child: Row(
        children: [
          Icon(
            _ac ? Icons.ac_unit_rounded : Icons.whatshot_rounded,
            color: _ac ? AppConstants.infoColor : AppConstants.warmAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _ac ? 'AC Available' : 'No AC',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textColor,
              ),
            ),
          ),
          Switch(
            value: _ac,
            onChanged: (v) => setState(() => _ac = v),
            activeThumbColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppConstants.cardElevation,
      ),
      child: Row(
        children: [
          Text(
            _rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppConstants.goldAccent,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded,
              color: AppConstants.goldAccent, size: 22),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppConstants.goldAccent,
                inactiveTrackColor: AppConstants.borderColor,
                thumbColor: AppConstants.goldAccent,
                overlayColor:
                    AppConstants.goldAccent.withValues(alpha: 0.2),
                trackHeight: 4,
              ),
              child: Slider(
                min: 1,
                max: 5,
                divisions: 8,
                value: _rating,
                onChanged: (v) => setState(() => _rating = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allFeatures.map((f) {
        final selected = _selectedFeatures.contains(f);
        return ScaleOnTap(
          scaleDown: 0.94,
          onTap: () => setState(() {
            if (selected) {
              _selectedFeatures.remove(f);
            } else {
              _selectedFeatures.add(f);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [
                        AppConstants.successColor,
                        Color(0xFF16A085),
                      ],
                    )
                  : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppConstants.successColor
                    : AppConstants.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.add_circle_outline_rounded,
                  size: 14,
                  color: selected
                      ? Colors.white
                      : AppConstants.lightTextColor,
                ),
                const SizedBox(width: 5),
                Text(
                  f,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppConstants.textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
