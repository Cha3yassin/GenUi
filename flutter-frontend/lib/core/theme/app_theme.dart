import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color terracotta = Color(0xFFB45745);
  static const Color deepTerracotta = Color(0xFF843B31);
  static const Color sand = Color(0xFFF7F1EA);
  static const Color paper = Color(0xFFFFFCF8);
  static const Color ink = Color(0xFF26211F);
  static const Color mutedInk = Color(0xFF6F625D);
  static const Color olive = Color(0xFF68775A);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: terracotta,
      brightness: Brightness.light,
      primary: terracotta,
      secondary: olive,
      surface: paper,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme.copyWith(
        primary: terracotta,
        onPrimary: Colors.white,
        secondary: olive,
        surface: paper,
        onSurface: ink,
        outline: const Color(0xFFE3D8CF),
      ),
      scaffoldBackgroundColor: sand,
      fontFamily: 'Roboto',
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: sand,
        foregroundColor: ink,
      ),
      cardTheme: CardTheme(
        color: paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE7DCD3)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFFFE1D8),
        side: const BorderSide(color: Color(0xFFE5D6CE)),
        labelStyle: _textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: _textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: _textTheme.bodyMedium?.copyWith(color: mutedInk),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE6DAD2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE6DAD2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: terracotta, width: 1.5),
        ),
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 38,
      height: 1.08,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.1,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 1.15,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: 1.22,
      fontWeight: FontWeight.w800,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      height: 1.28,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w500,
      color: mutedInk,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
  );
}
