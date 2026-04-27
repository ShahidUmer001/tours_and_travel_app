import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_auth_service.dart';
import '../services/user_listings_service.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';

class AddHotelScreen extends StatefulWidget {
  final UserHotel? existing;
  const AddHotelScreen({super.key, this.existing});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  double _rating = 4.0;
  String _category = 'Standard';
  String _imagePath = '';
  bool _saving = false;

  late AnimationController _animController;

  final List<String> _categories = [
    'Standard',
    'Deluxe',
    'Premium',
    'Luxury',
    'Resort',
    'Budget',
  ];

  final List<String> _allAmenities = [
    'WiFi',
    'Breakfast',
    'Parking',
    'Swimming Pool',
    'Gym',
    'Spa',
    'Restaurant',
    'Room Service',
    'AC',
    'Heating',
    'TV',
    'Laundry',
    'Pet Friendly',
    'Airport Shuttle',
  ];
  final Set<String> _selectedAmenities = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    if (widget.existing != null) {
      final h = widget.existing!;
      _nameController.text = h.name;
      _locationController.text = h.location;
      _cityController.text = h.city;
      _priceController.text = h.pricePerNight.toStringAsFixed(0);
      _descriptionController.text = h.description;
      _phoneController.text = h.contactPhone;
      _rating = h.rating;
      _category = h.category;
      _imagePath = h.imagePath;
      _selectedAmenities.addAll(h.amenities);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
      _snack('Please pick a hotel image', error: true);
      return;
    }
    if (_selectedAmenities.isEmpty) {
      _snack('Please select at least one amenity', error: true);
      return;
    }

    setState(() => _saving = true);

    final email = LocalAuthService.instance.currentEmail ?? 'guest';
    final ownerName =
        LocalAuthService.instance.currentFullName ?? 'Guest User';

    final hotel = UserHotel(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      ownerEmail: email,
      ownerName: ownerName,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      city: _cityController.text.trim(),
      pricePerNight: double.tryParse(_priceController.text.trim()) ?? 0,
      rating: _rating,
      description: _descriptionController.text.trim(),
      amenities: _selectedAmenities.toList(),
      category: _category,
      contactPhone: _phoneController.text.trim(),
      imagePath: _imagePath,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing != null) {
      await UserListingsService.instance.updateHotel(hotel);
      if (!mounted) return;
      _snack('Hotel updated successfully!');
    } else {
      await UserListingsService.instance.addHotel(hotel);
      if (!mounted) return;
      _snack('Hotel registered successfully!');
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
          widget.existing != null ? 'Edit Hotel' : 'Register Your Hotel',
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
              _sectionTitle('Hotel Details', Icons.hotel_rounded),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Hotel Name',
                icon: Icons.business_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _cityController,
                label: 'City (e.g. Hunza)',
                icon: Icons.location_city_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _locationController,
                label: 'Full Address',
                icon: Icons.place_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _priceController,
                label: 'Price per Night (Rs.)',
                icon: Icons.price_change_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
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
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_rounded,
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Category', Icons.category_rounded),
              const SizedBox(height: 10),
              _buildCategoryChips(),
              const SizedBox(height: 20),
              _sectionTitle('Rating', Icons.star_rounded),
              const SizedBox(height: 8),
              _buildRatingSelector(),
              const SizedBox(height: 20),
              _sectionTitle('Amenities', Icons.check_circle_rounded),
              const SizedBox(height: 10),
              _buildAmenities(),
              const SizedBox(height: 28),
              LiquidButton(
                label: _saving
                    ? 'SAVING...'
                    : widget.existing != null
                        ? 'UPDATE HOTEL'
                        : 'REGISTER HOTEL',
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _save,
                colors: const [
                  AppConstants.primaryDark,
                  AppConstants.primaryLight,
                ],
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
          gradient: AppConstants.primaryGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.35),
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
                    Icons.hotel_rounded,
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
                    text: 'List Your Hotel',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fill in your hotel details and reach travelers across Pakistan',
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
            color: AppConstants.primaryColor.withValues(alpha: 0.25),
            width: 2,
            style: BorderStyle.solid,
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
                          decoration: BoxDecoration(
                            gradient: AppConstants.primaryGradient,
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
                        'Tap to add hotel photo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textColor,
                        ),
                      ),
                      Text(
                        'JPG or PNG, up to 10MB',
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
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: AppConstants.primaryColor, size: 18),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppConstants.lightTextColor,
          fontSize: 14,
        ),
        prefixIcon: maxLines == 1
            ? Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final selected = _category == cat;
        return ScaleOnTap(
          scaleDown: 0.94,
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: selected ? AppConstants.primaryGradient : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppConstants.primaryColor
                    : AppConstants.borderColor,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              cat,
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

  Widget _buildAmenities() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allAmenities.map((a) {
        final selected = _selectedAmenities.contains(a);
        return ScaleOnTap(
          scaleDown: 0.94,
          onTap: () => setState(() {
            if (selected) {
              _selectedAmenities.remove(a);
            } else {
              _selectedAmenities.add(a);
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
                  a,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? Colors.white : AppConstants.textColor,
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
