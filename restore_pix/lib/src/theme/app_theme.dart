import 'package:flutter/material.dart';

class AppTheme {
  // Brand AI colors
  static const Color primaryPurple = Color(0xFF7A11FF);
  static const Color primaryPink = Color(0xFFFF1178);
  static const Color primaryCyan = Color(0xFF00F0FF);
  static const Color backgroundDark = Color(0xFF0D0E15);
  static const Color surfaceDark = Color(0xFF161824);
  static const Color cardDark = Color(0xFF1F2232);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSubtle = Color(0xFFA0A3B5);
  static const Color goldPremium = Color(0xFFFFD700);

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient proBadgeGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF7A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: primaryPink,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: textWhite,
        onSurface: textWhite,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textWhite),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textWhite,
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
