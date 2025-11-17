import 'package:flutter/material.dart';

/// Centralizes the dark, neon-accented palette inspired by modern music apps.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF05050A);
  static const Color surface = Color(0xFF0E111B);
  static const Color surfaceAlt = Color(0xFF161B2B);
  static const Color glass = Color(0x66FFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9FA6C3);
  static const Color accent = Color(0xFF8A7BFF);
  static const Color accentSecondary = Color(0xFFFF6F9C);
  static const Color accentTertiary = Color(0xFF4CE8F3);
}

class AppGradients {
  AppGradients._();

  static const Gradient hero = LinearGradient(
    colors: [
      Color(0xFF2C1AFF),
      Color(0xFFAD1AFF),
      Color(0xFFFF7D6E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient card = LinearGradient(
    colors: [
      Color(0xFF1E2236),
      Color(0xFF272040),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient miniPlayer = LinearGradient(
    colors: [
      Color(0xCC1C1F2B),
      Color(0xCC2B1E33),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  AppShadows._();

  static final softGlow = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.28),
      blurRadius: 48,
      spreadRadius: -16,
      offset: const Offset(0, 20),
    ),
  ];
}
