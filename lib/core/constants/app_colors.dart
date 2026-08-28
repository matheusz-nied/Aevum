import 'package:flutter/material.dart';

class AppColors {
  // Base backgrounds
  static const Color darkBackground = Color(0xFF0D0F12);
  static const Color darkSurface = Color(0xFF161A20);
  static const Color darkSurfaceElevated = Color(0xFF1E232B);
  static const Color darkSurfaceCard = Color(0xFF1A1F27);

  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F2F5);

  // Vibrant Accents (Inspired by references)
  static const Color coralNeon = Color(0xFFFF5722);    // Ref 1 (Tactile Dial)
  static const Color warmAmber = Color(0xFFFF9800);    // Ref 2 (Glowing Task theme)
  static const Color amberGlow = Color(0xFFFFB74D);
  static const Color sacredTeal = Color(0xFF00E5BC);   // Ref 4 (Apple Design sacred geometry)
  static const Color zenGreen = Color(0xFF4CAF50);     // Ref 3 (Forest calm)
  static const Color mysticPurple = Color(0xFF9C27B0); // Ref 5 (Orb inspiration)
  static const Color electricBlue = Color(0xFF2979FF);
  static const Color softRose = Color(0xFFE91E63);

  // Preset Colors for Tasks
  static const List<Color> taskColors = [
    coralNeon,
    warmAmber,
    sacredTeal,
    zenGreen,
    electricBlue,
    mysticPurple,
    softRose,
  ];

  // Glassmorphism overlays
  static Color glassDark = const Color(0xFF1E232B).withValues(alpha: 0.7);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.12);
  static Color glassLight = Colors.white.withValues(alpha: 0.85);
  static Color glassBorderLight = Colors.black.withValues(alpha: 0.08);

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8E99A8);
  static const Color textDark = Color(0xFF191D23);
}
