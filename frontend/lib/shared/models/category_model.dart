import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.nameEn,
    required this.icon,
    required this.accentColor,
  });

  final String id;
  final String nameAr;
  final String nameFr;
  final String nameEn;
  final IconData icon;
  final Color accentColor;

  /// Get the localized title based on locale code.
  String title([String locale = 'fr']) {
    return switch (locale) {
      'ar' => nameAr,
      'en' => nameEn,
      _ => nameFr,
    };
  }

  /// For backward compatibility with existing code.
  String get description => nameFr;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Support both backend API format (name_ar/name_fr/name_en)
    // and legacy mock format (title/description)
    final nameAr = json['name_ar'] as String? ?? json['title'] as String? ?? '';
    final nameFr = json['name_fr'] as String? ?? json['title'] as String? ?? '';
    final nameEn = json['name_en'] as String? ?? json['title'] as String? ?? '';

    return CategoryModel(
      id: json['id'] as String,
      nameAr: nameAr,
      nameFr: nameFr,
      nameEn: nameEn,
      icon: _iconFromName(json['icon'] as String),
      accentColor: json['accentColor'] != null
          ? Color(json['accentColor'] as int)
          : _colorFromSlug(json['id'] as String),
    );
  }

  static IconData _iconFromName(String name) {
    return switch (name) {
      'directions_car' || 'car' => Icons.directions_car_rounded,
      'home_work' || 'home' => Icons.home_work_rounded,
      'business_center' || 'briefcase' => Icons.business_center_rounded,
      'badge' || 'document_text' => Icons.badge_rounded,
      'receipt_percent' => Icons.receipt_long_rounded,
      'passport' => Icons.card_travel_rounded,
      'shield_check' => Icons.shield_rounded,
      'building_office' => Icons.apartment_rounded,
      _ => Icons.article_rounded,
    };
  }

  /// Generate consistent accent colors from category slug.
  static Color _colorFromSlug(String slug) {
    return switch (slug) {
      'civil_status' => const Color(0xFF68775A),
      'vehicles' => const Color(0xFFB45745),
      'taxation' => const Color(0xFF843B31),
      'residence' => const Color(0xFF5A6E77),
      'passports_travel' => const Color(0xFF6B5A77),
      'business' => const Color(0xFF6F625D),
      'social_security' => const Color(0xFF4A7768),
      'property' => const Color(0xFF7A6545),
      _ => const Color(0xFF5D6F62),
    };
  }
}
