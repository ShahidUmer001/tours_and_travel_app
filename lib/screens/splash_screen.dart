import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _bgController;
  late AnimationController _contentController;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.travel_explore_rounded,
      title: 'Explore Pakistan',
      subtitle: 'Discover breathtaking destinations across\nthe beautiful landscapes of Pakistan',
      gradient: const [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
      iconGradient: const [Color(0xFFFFD54F), Color(0xFFFF7043)],
    ),
    _OnboardingData(
      icon: Icons.hotel_rounded,
      title: 'Book Hotels & Transport',
      subtitle: 'Find the best hotels and reliable transport\nfor a comfortable travel experience',
      gradient: const [Color(0xFF11998E), Color(0xFF38EF7D), Color(0xFFB3F2E6)],
      iconGradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    _OnboardingData(
      icon: Icons.map_rounded,
      title: 'Plan Your Journey',
      subtitle: 'Create custom itineraries with weather updates,\nmaps, and real-time booking tracking',
      gradient: const [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
      iconGradient: const [Color(0xFF00BFA5), Color(0xFF00E5FF)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedGradientBackground(
            gradients: _pages.map((p) => p.gradient).toList(),
            duration: const Duration(seconds: 8),
            child: const SizedBox.expand(),
          ),

          // Floating particles
          const Positioned.fill(
            child: FloatingParticles(count: 18, maxRadius: 3),
          ),

          // Decorative blobs
          Positioned(
            top: -60,
            right: -40,
            child: FloatingAnimation(
              duration: const Duration(seconds: 5),
              offset: 14,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: FloatingAnimation(
              duration: const Duration(seconds: 6),
              offset: 18,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),

          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _contentController.reset();
                      _contentController.forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),

                // Dots indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == index ? 32 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: _currentPage == index
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                // Next / Get Started button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                  child: ScaleOnTap(
                    onTap: _nextPage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: GoogleFonts.poppins(
                              color: AppConstants.primaryDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            color: AppConstants.primaryDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glow
            FloatingAnimation(
              offset: 8,
              child: GlowPulse(
                glowColor: data.iconGradient.first,
                maxRadius: 50,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: data.iconGradient,
                    ).createShader(bounds),
                    child: Icon(
                      data.icon,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Title
            ShimmerText(
              text: data.title,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final List<Color> iconGradient;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.iconGradient,
  });
}
