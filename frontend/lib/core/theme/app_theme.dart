import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme — Warm, earthy, editorial aesthetic.
/// Inspired by Tunisian terracotta and sand.
class AppTheme {
  const AppTheme._();

  // ── Brand Colors ────────────────────────────────────────────────────────────
  static const Color terracotta = Color(0xFF1B3A4B);     // Deep navy-slate (primary)
  static const Color deepTerracotta = Color(0xFF0F2634);  // Darker shade
  static const Color warmCoral = Color(0xFF2E6B7B);       // Teal accent
  static const Color sand = Color(0xFFF4F5F7);            // Light professional grey
  static const Color paper = Color(0xFFFFFFFF);            // Pure white cards
  static const Color cream = Color(0xFFF8F9FA);            // Subtle off-white
  static const Color ink = Color(0xFF1A1D21);              // Near-black text
  static const Color mutedInk = Color(0xFF5F6B7A);         // Muted blue-grey
  static const Color olive = Color(0xFF2D7D6F);            // Professional teal-green
  static const Color softOlive = Color(0xFF5BA08F);        // Lighter teal
  static const Color borderLight = Color(0xFFE2E5EA);      // Clean grey border
  static const Color surfaceTint = Color(0xFFEDF3F5);      // Light blue tint

  // ── Role palettes ───────────────────────────────────────────────────────────
  /// Warm palette for Individual role
  static const Color individualAccent = Color(0xFF2E6B7B);
  static const Color individualBg = Color(0xFFF0F7F9);

  /// Professional palette for Enterprise role
  static const Color enterpriseAccent = Color(0xFF1B3A4B);
  static const Color enterpriseBg = Color(0xFFF0F2F5);

  // ── Enterprise action card colors ──────────────────────────────────────────
  static const Color darkNavy = Color(0xFF1B2A4A);
  static const Color actionYellow = Color(0xFFD4A017);
  static const Color actionBlue = Color(0xFF2E6B8A);
  static const Color actionGreen = Color(0xFF2D7D6F);
  static const Color actionOrange = Color(0xFFCC6B2C);

  // ── Category-specific design colors ─────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'civil_status': Color(0xFF3D6B7E),     // Steel blue
    'vehicles': Color(0xFF4A7C59),          // Forest green
    'taxation': Color(0xFF8B6914),          // Amber/gold
    'residence': Color(0xFF5A6E77),         // Slate grey
    'passports_travel': Color(0xFF5B4A8A),  // Royal purple
    'business': Color(0xFF1B3A4B),          // Deep navy
    'social_security': Color(0xFF2D7D6F),   // Teal
    'property': Color(0xFF7A5C3D),          // Warm brown
  };

  static const Map<String, IconData> categoryIcons = {
    'civil_status': Icons.balance_rounded,
    'vehicles': Icons.directions_car_rounded,
    'taxation': Icons.account_balance_rounded,
    'residence': Icons.home_work_rounded,
    'passports_travel': Icons.card_travel_rounded,
    'business': Icons.business_center_rounded,
    'social_security': Icons.shield_rounded,
    'property': Icons.apartment_rounded,
  };

  // ── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: terracotta,
      brightness: Brightness.light,
      primary: terracotta,
      secondary: olive,
      surface: paper,
    );

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

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
        titleTextStyle: GoogleFonts.plusJakartaSans(
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
          borderRadius: BorderRadius.circular(16),
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
          textStyle: GoogleFonts.plusJakartaSans(
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
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: terracotta,
          textStyle: GoogleFonts.plusJakartaSans(
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
        hintStyle: GoogleFonts.plusJakartaSans(
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
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        height: 1.22,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: mutedInk,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: mutedInk,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: mutedInk,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: mutedInk,
      ),
    );
  }
}
