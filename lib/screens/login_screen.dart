import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_auth_service.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSocialLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(error ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: error ? AppConstants.errorColor : AppConstants.successColor,
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack('Please fill all fields', error: true);
      return;
    }

    setState(() => _isLoading = true);

    final error = await LocalAuthService.instance.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      _showSnack('Login successful!');
      Navigator.of(context).pushAndRemoveUntil(
        PageTransitions.fadeScale(const HomeScreen()),
        (route) => false,
      );
    } else {
      _showSnack(error, error: true);
    }
  }

  void _handleSocialLogin(Future<String?> Function() signInMethod, String provider) async {
    if (_isSocialLoading) return;
    setState(() => _isSocialLoading = true);

    final error = await signInMethod();

    if (!mounted) return;
    setState(() => _isSocialLoading = false);

    if (error == null) {
      _showSnack('$provider login successful!');
      Navigator.of(context).pushAndRemoveUntil(
        PageTransitions.fadeScale(const HomeScreen()),
        (route) => false,
      );
    } else {
      _showSnack(error, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedGradientBackground(
        gradients: AppConstants.loginGradients,
        duration: const Duration(seconds: 8),
        child: Stack(
          children: [
            // Floating particles background
            const Positioned.fill(
              child: FloatingParticles(count: 22, maxRadius: 3),
            ),

            // Top image showcase - Car, Airplane, Hotel, Mountain
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                ),
                child: SafeArea(
                  child: SizedBox(
                    height: 180,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Top-left: Car
                        Positioned(
                          top: 8,
                          left: 12,
                          child: FloatingAnimation(
                            offset: 6,
                            duration: const Duration(seconds: 4),
                            child: _buildLoginImage(
                              'assets/images/login/car.jpg',
                              Icons.directions_car_rounded,
                              'Car',
                              100, 90,
                              18,
                            ),
                          ),
                        ),
                        // Top-center: Airplane (bigger)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: FloatingAnimation(
                              offset: 8,
                              duration: const Duration(seconds: 5),
                              child: _buildLoginImage(
                                'assets/images/login/airplane.jpg',
                                Icons.flight_rounded,
                                'Flight',
                                120, 110,
                                22,
                              ),
                            ),
                          ),
                        ),
                        // Top-right: Hotel
                        Positioned(
                          top: 8,
                          right: 12,
                          child: FloatingAnimation(
                            offset: 6,
                            duration: const Duration(seconds: 4),
                            child: _buildLoginImage(
                              'assets/images/login/hotel.jpg',
                              Icons.hotel_rounded,
                              'Hotel',
                              100, 90,
                              18,
                            ),
                          ),
                        ),
                        // Bottom-center: Mountain
                        Positioned(
                          bottom: -8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: FloatingAnimation(
                              offset: 7,
                              duration: const Duration(seconds: 6),
                              child: _buildLoginImage(
                                'assets/images/login/mountain.jpg',
                                Icons.terrain_rounded,
                                'Mountain',
                                110, 70,
                                20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Decorative blobs
            Positioned(
              bottom: -70,
              left: -50,
              child: FloatingAnimation(
                duration: const Duration(seconds: 5),
                offset: 16,
                child: const BlobDecoration(
                  size: 200,
                  colors: [Color(0xFF00BFA5), Color(0xFF00E5FF)],
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).viewInsets.bottom -
                        MediaQuery.of(context).padding.vertical -
                        16,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        _buildLogoSection(),
                        const SizedBox(height: 28),
                        _buildLoginCard(),
                        const SizedBox(height: 22),
                        _buildSocialLogin(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGO SECTION with glow + shimmer brand name
  // ============================================================
  Widget _buildLogoSection() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
        )),
        child: Column(
          children: [
            FloatingAnimation(
              offset: 6,
              child: GlowPulse(
                glowColor: AppConstants.goldAccent,
                maxRadius: 40,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFE3F2FD)],
                    ),
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    size: 62,
                    color: AppConstants.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ShimmerText(
              text: 'Tours and Travel',
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            TypewriterText(
              text: 'Explore the beauty of Pakistan',
              duration: const Duration(milliseconds: 1800),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN CARD — glass effect with premium form
  // ============================================================
  Widget _buildLoginCard() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
        )),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GradientText(
                    text: 'Welcome Back',
                    colors: const [
                      AppConstants.primaryDark,
                      AppConstants.primaryLight,
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Login to continue your journey',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppConstants.lightTextColor,
                ),
              ),
              const SizedBox(height: 26),

              StaggeredEntry(
                index: 0,
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 14),

              StaggeredEntry(
                index: 1,
                child: _buildPasswordField(),
              ),
              const SizedBox(height: 6),

              StaggeredEntry(
                index: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideUp(const ForgotPasswordScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: AppConstants.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Animated login button
              ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.5, 0.95, curve: Curves.elasticOut),
                  ),
                ),
                child: LiquidButton(
                  label: _isLoading ? 'LOGGING IN...' : 'LOGIN',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isLoading,
                  onPressed: _login,
                  colors: const [
                    AppConstants.primaryDark,
                    AppConstants.primaryLight,
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Sign Up row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.poppins(
                      color: AppConstants.lightTextColor,
                      fontSize: 14,
                    ),
                  ),
                  ScaleOnTap(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideUp(const SignupScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SOCIAL LOGIN ROW
  // ============================================================
  Widget _buildSocialLogin() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'Or continue with',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isSocialLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StaggeredEntry(
                  index: 0,
                  baseDelay: const Duration(milliseconds: 150),
                  child: _socialButton(
                    Icons.g_mobiledata_rounded,
                    Colors.red,
                    () => _handleSocialLogin(
                      LocalAuthService.instance.signInWithGoogle,
                      'Google',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                StaggeredEntry(
                  index: 1,
                  baseDelay: const Duration(milliseconds: 150),
                  child: _socialButton(
                    Icons.facebook,
                    Colors.blue,
                    () => _handleSocialLogin(
                      LocalAuthService.instance.signInWithFacebook,
                      'Facebook',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                StaggeredEntry(
                  index: 2,
                  baseDelay: const Duration(milliseconds: 150),
                  child: _socialButton(
                    Icons.apple,
                    Colors.black,
                    () => _handleSocialLogin(
                      LocalAuthService.instance.signInWithApple,
                      'Apple',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppConstants.lightTextColor,
          fontSize: 14,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppConstants.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: GoogleFonts.poppins(
          color: AppConstants.lightTextColor,
          fontSize: 14,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.lock_outline_rounded,
              color: Colors.white, size: 18),
        ),
        suffixIcon: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key: ValueKey(_obscurePassword),
              color: AppConstants.lightTextColor,
            ),
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppConstants.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginImage(
    String imagePath,
    IconData icon,
    String label,
    double width,
    double height,
    double radius,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: AppConstants.primaryDark.withValues(alpha: 0.5),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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
}
