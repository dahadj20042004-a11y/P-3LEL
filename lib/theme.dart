// lib/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryGreen = Color(0xFF2D7A3A);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color dangerRed = Color(0xFFE53935);
  static const Color warningYellow = Color(0xFFFFB300);
  static const Color safeGreen = Color(0xFF43A047);
  static const Color cardBg = Color(0xCC1A2E1A); // semi-transparent dark green
  static const Color cardBgLight = Color(0xBB0D1A0D);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: lightGreen,
          secondary: accentGold,
          surface: const Color(0xFF0D1A0D),
          error: dangerRed,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xCC0D1A0D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A2E1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2D5A2D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: lightGreen, width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF90A490)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFCCDDCC)),
        ),
        fontFamily: 'Roboto',
      );
}
