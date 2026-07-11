import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF0E0E10);
  static const surface = Color(0xFF18181B);
  static const surface2 = Color(0xFF1F1F23);
  static const border = Color(0xFF2A2A30);
  static const textPrimary = Color(0xFFE4E4E7);
  static const textMuted = Color(0xFF52525B);
  static const muted2 = Color(0xFF3F3F46);
  // Default accent — overridden at runtime via AccentProvider
  static const defaultAccent = Color(0xFF7C3AED);

  static ThemeData build(Color accent) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.dark(
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
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withOpacity(0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: accent);
        }
        return const IconThemeData(color: AppTheme.textMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w500);
        }
        return const TextStyle(color: AppTheme.textMuted, fontSize: 12);
      }),
    ),
    dividerColor: border,
    cardColor: surface,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: accent),
    ),
  );
}
