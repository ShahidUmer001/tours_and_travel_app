import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

class WeatherScreen extends StatefulWidget {
  final String? destinationName;

  const WeatherScreen({super.key, this.destinationName});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  int _selectedDestination = 0;
  final bool _isLoading = false;
  Map<String, dynamic>? _weatherData;

  final List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Hunza Valley',
      'lat': 36.3167,
      'lon': 74.6500,
      'icon': Icons.landscape_rounded,
      'color': const Color(0xFF0D47A1),
    },
    {
      'name': 'Skardu',
      'lat': 35.2972,
      'lon': 75.6333,
      'icon': Icons.terrain_rounded,
      'color': const Color(0xFF11998E),
    },
    {
      'name': 'Swat Valley',
      'lat': 35.2227,
      'lon': 72.3544,
      'icon': Icons.park_rounded,
      'color': const Color(0xFF667EEA),
    },
    {
      'name': 'Naran Kaghan',
      'lat': 34.9091,
      'lon': 73.6506,
      'icon': Icons.water_rounded,
      'color': const Color(0xFFFF7043),
    },
    {
      'name': 'Fairy Meadows',
      'lat': 35.3755,
      'lon': 74.5880,
      'icon': Icons.grass_rounded,
      'color': const Color(0xFF764BA2),
    },
  ];

  // Static weather data for offline mode
  final List<Map<String, dynamic>> _staticWeather = [
    {'temp': 18, 'condition': 'Partly Cloudy', 'humidity': 45, 'wind': 12, 'icon': Icons.wb_cloudy_rounded, 'high': 22, 'low': 8},
    {'temp': 12, 'condition': 'Clear Sky', 'humidity': 35, 'wind': 8, 'icon': Icons.wb_sunny_rounded, 'high': 16, 'low': 2},
    {'temp': 24, 'condition': 'Sunny', 'humidity': 55, 'wind': 10, 'icon': Icons.wb_sunny_rounded, 'high': 28, 'low': 16},
    {'temp': 20, 'condition': 'Light Rain', 'humidity': 65, 'wind': 15, 'icon': Icons.water_drop_rounded, 'high': 23, 'low': 12},
    {'temp': 10, 'condition': 'Foggy', 'humidity': 80, 'wind': 5, 'icon': Icons.cloud_rounded, 'high': 14, 'low': 4},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    if (widget.destinationName != null) {
      final idx = _destinations.indexWhere(
          (d) => d['name'].toString().toLowerCase().contains(
              widget.destinationName!.toLowerCase()));
      if (idx >= 0) _selectedDestination = idx;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentWeather =>
      _staticWeather[_selectedDestination];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDestinationSelector(),
                  const SizedBox(height: 24),
                  _buildMainWeatherCard(),
                  const SizedBox(height: 20),
                  _buildWeatherDetails(),
                  const SizedBox(height: 20),
                  _buildForecast(),
                  const SizedBox(height: 20),
                  _buildTravelTips(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final dest = _destinations[_selectedDestination];
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: dest['color'] as Color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Weather Updates',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [dest['color'] as Color, (dest['color'] as Color).withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationSelector() {
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Destination',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.textColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                final dest = _destinations[index];
                final isSelected = _selectedDestination == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDestination = index);
                    _animController.reset();
                    _animController.forward();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [
                              dest['color'] as Color,
                              (dest['color'] as Color).withValues(alpha: 0.7),
                            ])
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? (dest['color'] as Color).withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          dest['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : dest['color'] as Color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dest['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppConstants.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    final weather = _currentWeather;
    final dest = _destinations[_selectedDestination];

    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              dest['color'] as Color,
              (dest['color'] as Color).withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (dest['color'] as Color).withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: Colors.white.withValues(alpha: 0.9), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      dest['name'] as String,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather['temp']}°C',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          weather['condition'] as String,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    FloatingAnimation(
                      offset: 6,
                      child: Icon(
                        weather['icon'] as IconData,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMiniStat(Icons.arrow_upward_rounded, 'H: ${weather['high']}°'),
                    const SizedBox(width: 20),
                    _buildMiniStat(Icons.arrow_downward_rounded, 'L: ${weather['low']}°'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    final weather = _currentWeather;
    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 300),
      child: Row(
        children: [
          Expanded(
            child: _buildDetailCard(
              Icons.water_drop_rounded,
              'Humidity',
              '${weather['humidity']}%',
              const Color(0xFF42A5F5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDetailCard(
              Icons.air_rounded,
              'Wind',
              '${weather['wind']} km/h',
              const Color(0xFF00BFA5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDetailCard(
              Icons.visibility_rounded,
              'Visibility',
              '10 km',
              const Color(0xFFFF7043),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConstants.textColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppConstants.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecast() {
    final List<Map<String, dynamic>> forecast = [
      {'day': 'Mon', 'temp': _currentWeather['temp'] + 2, 'icon': Icons.wb_sunny_rounded},
      {'day': 'Tue', 'temp': _currentWeather['temp'] - 1, 'icon': Icons.wb_cloudy_rounded},
      {'day': 'Wed', 'temp': _currentWeather['temp'] + 1, 'icon': Icons.wb_sunny_rounded},
      {'day': 'Thu', 'temp': _currentWeather['temp'] - 3, 'icon': Icons.water_drop_rounded},
      {'day': 'Fri', 'temp': _currentWeather['temp'], 'icon': Icons.cloud_rounded},
    ];

    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5-Day Forecast',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: forecast.map((f) {
                return Column(
                  children: [
                    Text(
                      f['day'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      f['icon'] as IconData,
                      color: AppConstants.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${f['temp']}°',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelTips() {
    final tips = [
      'Pack warm layers for mountain regions',
      'Carry rain gear during monsoon season',
      'Stay hydrated at high altitudes',
      'Check weather before departure',
    ];

    return AnimatedFadeSlide(
      delay: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel Tips',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.warningColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tips_and_updates_rounded,
                          color: AppConstants.warningColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppConstants.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
