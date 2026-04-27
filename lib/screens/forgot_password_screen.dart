import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  final bool _obscureNew = true;
  final bool _obscureConfirm = true;
  int _currentStep = 0; // 0: email, 1: success message

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
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
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor:
              error ? AppConstants.errorColor : AppConstants.successColor,
          duration: const Duration(milliseconds: 2000),
        ),
      );
  }

  void _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter your email address', error: true);
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showSnack('Please enter a valid email address', error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _currentStep = 1;
      });
      _animController.reset();
      _animController.forward();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String msg = 'Something went wrong';
      if (e.code == 'user-not-found') {
        msg = 'No account found with this email';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address';
      }
      _showSnack(msg, error: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Error: ${e.toString()}', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        gradients: AppConstants.loginGradients,
        duration: const Duration(seconds: 8),
        child: Stack(
          children: [
            const Positioned.fill(
              child: FloatingParticles(count: 16, maxRadius: 3),
            ),
            Positioned(
              top: -50,
              left: -40,
              child: FloatingAnimation(
                duration: const Duration(seconds: 5),
                offset: 14,
                child: const BlobDecoration(
                  size: 180,
                  colors: [Color(0xFFFFC107), Color(0xFFFF7043)],
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -50,
              child: FloatingAnimation(
                duration: const Duration(seconds: 6),
                offset: 16,
                child: const BlobDecoration(
                  size: 200,
                  colors: [Color(0xFF00BFA5), Color(0xFF00E5FF)],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: ScaleOnTap(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Icon
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
                      ),
                      child: FloatingAnimation(
                        offset: 6,
                        child: GlowPulse(
                          glowColor: AppConstants.goldAccent,
                          maxRadius: 40,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white, Color(0xFFE3F2FD)],
                              ),
                            ),
                            child: Icon(
                              _currentStep == 0
                                  ? Icons.lock_reset_rounded
                                  : Icons.mark_email_read_rounded,
                              size: 50,
                              color: AppConstants.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Card
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve:
                            const Interval(0.2, 0.7, curve: Curves.easeOut),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.2, 0.7,
                              curve: Curves.easeOutCubic),
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
                          child: _currentStep == 0
                              ? _buildEmailStep()
                              : _buildSuccessStep(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          text: 'Forgot Password?',
          colors: const [AppConstants.primaryDark, AppConstants.primaryLight],
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppConstants.lightTextColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),

        // Email field
        StaggeredEntry(
          index: 0,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Email Address',
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
                child: const Icon(Icons.email_outlined,
                    color: Colors.white, size: 18),
              ),
              filled: true,
              fillColor: const Color(0xFFF4F6FB),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                    color: AppConstants.primaryColor, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Send button
        LiquidButton(
          label: _isLoading ? 'SENDING...' : 'SEND RESET LINK',
          icon: Icons.send_rounded,
          isLoading: _isLoading,
          onPressed: _sendResetEmail,
          colors: const [AppConstants.primaryDark, AppConstants.primaryLight],
        ),
        const SizedBox(height: 20),

        // Back to login
        Center(
          child: ScaleOnTap(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded,
                    size: 16, color: AppConstants.primaryColor),
                const SizedBox(width: 6),
                Text(
                  'Back to Login',
                  style: GoogleFonts.poppins(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppConstants.accentGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppConstants.accentColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        GradientText(
          text: 'Email Sent!',
          colors: const [AppConstants.primaryDark, AppConstants.primaryLight],
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppConstants.lightTextColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Check your inbox and follow the link to reset your password.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppConstants.lightTextColor,
          ),
        ),
        const SizedBox(height: 28),
        LiquidButton(
          label: 'BACK TO LOGIN',
          icon: Icons.login_rounded,
          onPressed: () => Navigator.pop(context),
          colors: const [AppConstants.primaryDark, AppConstants.primaryLight],
        ),
        const SizedBox(height: 16),
        ScaleOnTap(
          onTap: () {
            setState(() => _currentStep = 0);
            _animController.reset();
            _animController.forward();
          },
          child: Text(
            'Didn\'t receive? Resend',
            style: GoogleFonts.poppins(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
