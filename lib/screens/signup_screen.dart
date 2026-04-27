import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_auth_service.dart';
import '../utils/animations.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animController;

  // Custom gradient palette for signup (aurora theme)
  static const List<List<Color>> _signupGradients = [
    [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF7986CB)],
    [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFBA68C8)],
    [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
    [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF7986CB)],
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(error ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ]),
          backgroundColor:
              error ? AppConstants.errorColor : AppConstants.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _signup() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _snack('Please fill all fields', error: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _snack('Passwords do not match', error: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _snack('Password must be at least 6 characters', error: true);
      return;
    }

    setState(() => _isLoading = true);

    final error = await LocalAuthService.instance.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      _snack('Account created! Please login to continue.');
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeSlide(const LoginScreen()),
      );
    } else {
      _snack(error, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedGradientBackground(
        gradients: _signupGradients,
        duration: const Duration(seconds: 10),
        child: Stack(
          children: [
            const Positioned.fill(
              child: FloatingParticles(count: 20, maxRadius: 3),
            ),
            Positioned(
              top: -50,
              left: -60,
              child: FloatingAnimation(
                offset: 14,
                child: const BlobDecoration(
                  size: 200,
                  colors: [Color(0xFF9575CD), Color(0xFF7986CB)],
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -50,
              child: FloatingAnimation(
                duration: const Duration(seconds: 6),
                offset: 18,
                child: const BlobDecoration(
                  size: 220,
                  colors: [Color(0xFFFFAB40), Color(0xFFFF7043)],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildTopBar(),
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildFormCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        ScaleOnTap(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
        )),
        child: Column(
          children: [
            FloatingAnimation(
              offset: 6,
              child: GlowPulse(
                glowColor: const Color(0xFFFFC107),
                maxRadius: 36,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFE8EAF6)],
                    ),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 44,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ShimmerText(
              text: 'Create Account',
              highlightColor: const Color(0xFFFFD54F),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            TypewriterText(
              text: 'Start your journey with us',
              duration: const Duration(milliseconds: 1600),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.75, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.2, 0.75, curve: Curves.easeOutCubic),
        )),
        child: Container(
          padding: const EdgeInsets.all(22),
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
            children: [
              StaggeredEntry(
                index: 0,
                child: _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 12),
              StaggeredEntry(
                index: 1,
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 12),
              StaggeredEntry(
                index: 2,
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 12),
              StaggeredEntry(
                index: 3,
                child: _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 12),
              StaggeredEntry(
                index: 4,
                child: _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscure: _obscureConfirmPassword,
                  onToggle: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 22),

              ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.6, 0.95, curve: Curves.elasticOut),
                  ),
                ),
                child: LiquidButton(
                  label: _isLoading ? 'CREATING...' : 'CREATE ACCOUNT',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isLoading,
                  onPressed: _signup,
                  colors: const [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.poppins(
                      color: AppConstants.lightTextColor,
                      fontSize: 14,
                    ),
                  ),
                  ScaleOnTap(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageTransitions.fadeSlide(const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        color: Colors.indigo.shade700,
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
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3949AB), Color(0xFF7986CB)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo.shade700, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppConstants.lightTextColor,
          fontSize: 14,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3949AB), Color(0xFF7986CB)],
            ),
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
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key: ValueKey(obscure),
              color: AppConstants.lightTextColor,
            ),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo.shade700, width: 2),
        ),
      ),
    );
  }
}
