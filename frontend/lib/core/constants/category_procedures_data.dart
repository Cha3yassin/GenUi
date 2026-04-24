import 'package:flutter/material.dart';

/// Static mapping of real Tunisian administrative procedures per category.
/// Each procedure has a slug (used for GenUI lookup) and trilingual titles.
/// The icons are Material Design icons that represent each procedure.
class CategoryProceduresData {
  CategoryProceduresData._();

  /// Each entry: { slug, icon, name_fr, name_en, name_ar }
  static const Map<String, List<Map<String, dynamic>>> procedures = {
    'civil_status': [
      {
        'slug': 'marriage-certificate',
        'icon': 'favorite',
        'name_fr': 'Mariage',
        'name_en': 'Marriage',
        'name_ar': 'زواج',
      },
      {
        'slug': 'national-id-card-cin',
        'icon': 'badge',
        'name_fr': 'CIN',
        'name_en': 'ID Card',
        'name_ar': 'بطاقة هوية',
      },
      {
        'slug': 'birth-certificate',
        'icon': 'child_care',
        'name_fr': 'Naissance',
        'name_en': 'Birth',
        'name_ar': 'ولادة',
      },
      {
        'slug': 'death-certificate',
        'icon': 'description',
        'name_fr': 'Décès',
        'name_en': 'Death',
        'name_ar': 'وفاة',
      },
      {
        'slug': 'family-record-book-livret-de-famille',
        'icon': 'family_restroom',
        'name_fr': 'Livret de famille',
        'name_en': 'Family book',
        'name_ar': 'دفتر عائلي',
      },
    ],
    'passports_travel': [
      {
        'slug': 'new-passport-tunisia',
        'icon': 'card_travel',
        'name_fr': 'Nouveau passeport',
        'name_en': 'New passport',
        'name_ar': 'جواز سفر جديد',
      },
      {
        'slug': 'passport-renewal',
        'icon': 'autorenew',
        'name_fr': 'Renouvellement',
        'name_en': 'Renewal',
        'name_ar': 'تجديد',
      },
      {
        'slug': 'travel-visa-application',
        'icon': 'flight_takeoff',
        'name_fr': 'Visa voyage',
        'name_en': 'Travel visa',
        'name_ar': 'تأشيرة سفر',
      },
    ],
    'vehicles': [
      {
        'slug': 'buy-used-car',
        'icon': 'directions_car',
        'name_fr': 'Achat voiture',
        'name_en': 'Buy car',
        'name_ar': 'شراء سيارة',
      },
      {
        'slug': 'carte-grise-transfer',
        'icon': 'swap_horiz',
        'name_fr': 'Carte grise',
        'name_en': 'Registration',
        'name_ar': 'بطاقة رمادية',
      },
      {
        'slug': 'driving-license-tunisia',
        'icon': 'credit_card',
        'name_fr': 'Permis',
        'name_en': 'License',
        'name_ar': 'رخصة',
      },
      {
        'slug': 'vehicle-technical-inspection-controle-technique',
        'icon': 'build',
        'name_fr': 'Contrôle technique',
        'name_en': 'Inspection',
        'name_ar': 'فحص فني',
      },
    ],
    'residence': [
      {
        'slug': 'change-of-address-tunisia',
        'icon': 'location_on',
        'name_fr': 'Changement adresse',
        'name_en': 'Change address',
        'name_ar': 'تغيير عنوان',
      },
      {
        'slug': 'residency-certificate-tunisia',
        'icon': 'home',
        'name_fr': 'Certificat résidence',
        'name_en': 'Residency cert.',
        'name_ar': 'شهادة إقامة',
      },
      {
        'slug': 'housing-permit-tunisia',
        'icon': 'apartment',
        'name_fr': 'Permis habiter',
        'name_en': 'Housing permit',
        'name_ar': 'رخصة سكن',
      },
    ],
    'property': [
      {
        'slug': 'buy-property-tunisia',
        'icon': 'real_estate_agent',
        'name_fr': 'Achat immobilier',
        'name_en': 'Buy property',
        'name_ar': 'شراء عقار',
      },
      {
        'slug': 'land-title-titre-foncier',
        'icon': 'landscape',
        'name_fr': 'Titre foncier',
        'name_en': 'Land title',
        'name_ar': 'رسم عقاري',
      },
      {
        'slug': 'rental-contract-registration-tunisia',
        'icon': 'edit_document',
        'name_fr': 'Contrat location',
        'name_en': 'Rental contract',
        'name_ar': 'عقد إيجار',
      },
    ],
    'business': [
      {
        'slug': 'register-company-sarl-tunisia',
        'icon': 'business',
        'name_fr': 'Créer SARL',
        'name_en': 'Register SARL',
        'name_ar': 'تأسيس شركة',
      },
      {
        'slug': 'rne-registration-tunisia',
        'icon': 'app_registration',
        'name_fr': 'Inscription RNE',
        'name_en': 'RNE registration',
        'name_ar': 'تسجيل RNE',
      },
      {
        'slug': 'patent-registration-tunisia',
        'icon': 'receipt_long',
        'name_fr': 'Patente',
        'name_en': 'Patent',
        'name_ar': 'باتيندة',
      },
    ],
    'taxation': [
      {
        'slug': 'tax-declaration-tunisia',
        'icon': 'calculate',
        'name_fr': 'Déclaration fiscale',
        'name_en': 'Tax declaration',
        'name_ar': 'تصريح ضريبي',
      },
      {
        'slug': 'tva-registration-tunisia',
        'icon': 'percent',
        'name_fr': 'TVA',
        'name_en': 'VAT registration',
        'name_ar': 'تسجيل أداء',
      },
      {
        'slug': 'quitus-fiscal-tax-clearance-tunisia',
        'icon': 'verified',
        'name_fr': 'Quitus fiscal',
        'name_en': 'Tax clearance',
        'name_ar': 'براءة ذمة',
      },
    ],
    'social_security': [
      {
        'slug': 'cnss-registration-tunisia',
        'icon': 'shield',
        'name_fr': 'CNSS',
        'name_en': 'CNSS',
        'name_ar': 'CNSS',
      },
      {
        'slug': 'cnam-enrollment-tunisia',
        'icon': 'health_and_safety',
        'name_fr': 'CNAM',
        'name_en': 'CNAM',
        'name_ar': 'CNAM',
      },
      {
        'slug': 'retirement-pension-tunisia',
        'icon': 'elderly',
        'name_fr': 'Retraite',
        'name_en': 'Retirement',
        'name_ar': 'تقاعد',
      },
    ],
  };

  /// Get procedures for a category, returns empty list if not found.
  static List<Map<String, dynamic>> forCategory(String categoryId) {
    return procedures[categoryId] ?? [];
  }

  /// Get the localized name for a procedure entry.
  static String localizedName(Map<String, dynamic> proc, String locale) {
    return switch (locale) {
      'ar' => proc['name_ar'] as String,
      'en' => proc['name_en'] as String,
      _ => proc['name_fr'] as String,
    };
  }

  /// Map icon name string to IconData.
  static IconData iconFor(String iconName) {
    return switch (iconName) {
      'favorite' => Icons.favorite_rounded,
      'badge' => Icons.badge_rounded,
      'child_care' => Icons.child_care_rounded,
      'description' => Icons.description_rounded,
      'family_restroom' => Icons.family_restroom_rounded,
      'card_travel' => Icons.card_travel_rounded,
      'autorenew' => Icons.autorenew_rounded,
      'flight_takeoff' => Icons.flight_takeoff_rounded,
      'directions_car' => Icons.directions_car_rounded,
      'swap_horiz' => Icons.swap_horiz_rounded,
      'credit_card' => Icons.credit_card_rounded,
      'build' => Icons.build_rounded,
      'location_on' => Icons.location_on_rounded,
      'home' => Icons.home_rounded,
      'apartment' => Icons.apartment_rounded,
      'real_estate_agent' => Icons.real_estate_agent_rounded,
      'landscape' => Icons.landscape_rounded,
      'edit_document' => Icons.edit_document,
      'business' => Icons.business_rounded,
      'app_registration' => Icons.app_registration_rounded,
      'receipt_long' => Icons.receipt_long_rounded,
      'calculate' => Icons.calculate_rounded,
      'percent' => Icons.percent_rounded,
      'verified' => Icons.verified_rounded,
      'shield' => Icons.shield_rounded,
      'health_and_safety' => Icons.health_and_safety_rounded,
      'elderly' => Icons.elderly_rounded,
      _ => Icons.article_rounded,
    };
  }
}
