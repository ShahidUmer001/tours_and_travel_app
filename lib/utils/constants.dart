import 'package:flutter/material.dart';

class AppConstants {
  // ===== Primary Brand Colors =====
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primarySoft = Color(0xFFE3F2FD);

  // ===== Accent / Secondary =====
  static const Color accentColor = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFF00E5FF);
  static const Color warmAccent = Color(0xFFFF7043);
  static const Color warmLight = Color(0xFFFFAB40);
  static const Color goldAccent = Color(0xFFFFC107);

  // ===== Surfaces =====
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color surfaceColor = Colors.white;
  static const Color cardShadow = Color(0x1A0D47A1);

  // ===== Text =====
  static const Color textColor = Color(0xFF0F1624);
  static const Color textSecondary = Color(0xFF4A5366);
  static const Color lightTextColor = Color(0xFF7A8396);
  static const Color borderColor = Color(0xFFE3E8F0);
  static const Color dividerColor = Color(0xFFEEF1F6);

  // ===== Status =====
  static const Color successColor = Color(0xFF2ECC71);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color infoColor = Color(0xFF3498DB);

  // ===== Premium Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFFAB40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFFD54F), Color(0xFFFFECB3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF81D4FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFB347), Color(0xFFFFD93D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient midnightGradient = LinearGradient(
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== Animated gradient sets =====
  static const List<List<Color>> loginGradients = [
    [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
    [Color(0xFF11998E), Color(0xFF38EF7D), Color(0xFFB3F2E6)],
    [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
    [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
  ];

  // ===== Sizes =====
  static const double defaultRadius = 16.0;
  static const double cardRadius = 24.0;
  static const double pillRadius = 999.0;
  static const double defaultPadding = 16.0;
  static const double pagePadding = 20.0;
  static const double buttonHeight = 54.0;

  // ===== Shadows =====
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0D47A1).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardElevation => [
        BoxShadow(
          color: const Color(0xFF0D47A1).withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.45),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  // ===== Animation Durations =====
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animStagger = Duration(milliseconds: 800);
}
