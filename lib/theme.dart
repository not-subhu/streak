import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF0E0E10);
  static const surface = Color(0xFF18181B);
  static const surface2 = Color(0xFF1F1F23);
  static const border = Color(0xFF2A2A30);
  static const textPrimary = Color(0xFFE4E4E7);
  static const textMuted = Color(0xFF52525B);
  static const muted2 = Color(0xFF3F3F46);
  static const accent = Color(0xFF7C3AED);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: accent,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: accent,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerColor: border,
    cardColor: surface,
  );
}
