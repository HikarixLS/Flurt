import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF080B11);
  static const Color surface = Color(0xFF0F1420);
  static const Color surfaceElevated = Color(0xFF161E2E);
  static const Color surfaceLight = Color(0xFF1F293D);
  static const Color cardBg = Color(0xFF121824);

  // Brand Accents
  static const Color primary = Color(0xFF8B5CF6); // Electric Violet
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  
  static const Color secondary = Color(0xFF06B6D4); // Neon Cyan
  static const Color secondaryLight = Color(0xFF22D3EE);
  
  static const Color accentRose = Color(0xFFF43F5E); // Ruby Flame
  static const Color accentAmber = Color(0xFFFBBF24); // Star Gold
  static const Color accentEmerald = Color(0xFF10B981); // Online Green

  // Texts
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Borders & Dividers
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderLight = Color(0x26FFFFFF);
  static const Color borderActive = Color(0x808B5CF6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x99080B11),
      Color(0xEE080B11),
      Color(0xFF080B11),
    ],
    stops: [0.0, 0.45, 0.8, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x33000000),
      Color(0xE6080B11),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
