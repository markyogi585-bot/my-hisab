import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds & Surface
  static const Color background = Color(0xFF090D1A);
  static const Color backgroundAlt = Color(0xFF0F1528);
  static const Color surface = Color(0xFF141C33);
  static const Color surfaceElevated = Color(0xFF1B2442);
  static const Color surfaceCard = Color(0xFF131B32);
  static const Color surfaceCardLight = Color(0xFF1E2849);

  // Borders & Dividers
  static const Color border = Color(0xFF243054);
  static const Color borderSubtle = Color(0xFF1B243F);
  static const Color borderGlow = Color(0xFF3B82F6);

  // Brand Accents
  static const Color primary = Color(0xFF3B82F6); // Electric Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF8B5CF6); // Neon Purple
  static const Color accentPink = Color(0xFFEC4899); // Vibrant Pink
  static const Color accentCyan = Color(0xFF06B6D4);

  // Financial Semantics
  static const Color income = Color(0xFF10B981); // Mint Neon Green
  static const Color incomeBackground = Color(0xFF064E3B);
  static const Color expense = Color(0xFFEF4444); // Neon Coral / Rose
  static const Color expenseBackground = Color(0xFF7F1D1D);
  static const Color warning = Color(0xFFF59E0B); // Amber / Yellow

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF475569);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF17203B), Color(0xFF10172C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [Color(0xFF1A2447), Color(0xFF11172F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ambient Glow Shadow
  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.35, double blur = 18}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];
}
