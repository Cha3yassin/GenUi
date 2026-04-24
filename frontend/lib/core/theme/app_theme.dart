import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme — Warm, earthy, editorial aesthetic.
/// Inspired by Tunisian terracotta and sand.
class AppTheme {
  const AppTheme._();

  // ── Brand Colors ────────────────────────────────────────────────────────────
  static const Color terracotta = Color(0xFFB45745);
  static const Color deepTerracotta = Color(0xFF843B31);
  static const Color warmCoral = Color(0xFFD4715E);
  static const Color sand = Color(0xFFF5EFE7);
  static const Color paper = Color(0xFFFFFBF6);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color ink = Color(0xFF1A1614);
  static const Color mutedInk = Color(0xFF6F625D);
  static const Color olive = Color(0xFF5E7049);
  static const Color softOlive = Color(0xFF8A9A72);
  static const Color borderLight = Color(0xFFE8DFD6);
  static const Color surfaceTint = Color(0xFFFFF0EA);

  // ── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: terracotta,
      brightness: Brightness.light,
      primary: terracotta,
      secondary: olive,
      surface: paper,
    );

    final baseTextTheme = GoogleFonts.dmSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme.copyWith(
        primary: terracotta,
        onPrimary: Colors.white,
        secondary: olive,
        tertiary: warmCoral,
        surface: paper,
        onSurface: ink,
        outline: borderLight,
        surfaceContainerHighest: cream,
      ),
      scaffoldBackgroundColor: sand,
      textTheme: _buildTextTheme(baseTextTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: sand,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: surfaceTint,
        side: const BorderSide(color: borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: borderLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: terracotta,
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: mutedInk.withOpacity(0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: terracotta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: paper,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: paper,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  // ── Typography ──────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: ink,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 26,
        height: 1.18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: ink,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 22,
        height: 1.22,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: mutedInk,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: mutedInk,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: mutedInk,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: mutedInk,
      ),
    );
  }
}
