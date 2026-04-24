/// Simple map-based i18n for the Fbureaucracy app.
/// Supports: fr (French), en (English), ar (Arabic).
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _strings = {
    'app_name': {
      'fr': 'Fbureaucracy',
      'en': 'Fbureaucracy',
      'ar': 'إف بيروقراطية',
    },
    'app_tagline': {
      'fr': 'Les démarches tunisiennes, étape par étape.',
      'en': 'Tunisian procedures, step by step.',
      'ar': 'الإجراءات التونسية، خطوة بخطوة.',
    },
    'browse_by_category': {
      'fr': 'Parcourir par catégorie',
      'en': 'Browse by category',
      'ar': 'تصفح حسب الفئة',
    },
    'category_subtitle': {
      'fr': "Choisissez le domaine administratif souhaité.",
      'en': 'Pick the administration area you need.',
      'ar': 'اختر المجال الإداري المطلوب.',
    },
    'popular_this_week': {
      'fr': 'Populaires cette semaine',
      'en': 'Popular this week',
      'ar': 'الأكثر شيوعاً هذا الأسبوع',
    },
    'popular_subtitle': {
      'fr': 'Procédures fréquemment consultées.',
      'en': 'Common procedures people are checking now.',
      'ar': 'الإجراءات الشائعة التي يبحث عنها الناس الآن.',
    },
    'search_hint': {
      'fr': 'Chercher: carte grise, passeport...',
      'en': 'Search: carte grise, passport...',
      'ar': 'ابحث: بطاقة رمادية، جواز سفر...',
    },
    'trust_title': {
      'fr': "Guide avant le guichet",
      'en': 'Guidance before the counter',
      'ar': 'إرشاد قبل الشباك',
    },
    'trust_body': {
      'fr':
          'Fbureaucracy organise les documents, frais et bureaux pour planifier vos visites avec moins d\'incertitude.',
      'en':
          'Fbureaucracy organizes documents, fees and offices so you can plan visits with less uncertainty.',
      'ar':
          'يقوم Fbureaucracy بتنظيم الوثائق والرسوم والمكاتب حتى تتمكن من التخطيط لزياراتك بأقل قدر من عدم اليقين.',
    },
    'sign_in': {
      'fr': 'Se connecter',
      'en': 'Sign In',
      'ar': 'تسجيل الدخول',
    },
    'sign_in_with_google': {
      'fr': 'Se connecter avec Google',
      'en': 'Sign in with Google',
      'ar': 'تسجيل الدخول بحساب جوجل',
    },
    'sign_out': {
      'fr': 'Déconnexion',
      'en': 'Sign Out',
      'ar': 'تسجيل الخروج',
    },
    'choose_role': {
      'fr': 'Choisissez votre profil',
      'en': 'Choose your profile',
      'ar': 'اختر ملفك الشخصي',
    },
    'individual': {
      'fr': 'Individuel',
      'en': 'Individual',
      'ar': 'فردي',
    },
    'individual_desc': {
      'fr': 'Passeport, CIN, véhicules...',
      'en': 'Passport, ID card, vehicles...',
      'ar': 'جواز سفر، بطاقة هوية، مركبات...',
    },
    'enterprise': {
      'fr': 'Entreprise',
      'en': 'Enterprise',
      'ar': 'مؤسسة',
    },
    'enterprise_desc': {
      'fr': 'Création, fiscalité, registre...',
      'en': 'Registration, taxation, registry...',
      'ar': 'تأسيس، ضرائب، سجل...',
    },
    'history': {
      'fr': 'Historique',
      'en': 'History',
      'ar': 'السجل',
    },
    'no_history': {
      'fr': 'Aucun historique pour le moment.',
      'en': 'No history yet.',
      'ar': 'لا يوجد سجل بعد.',
    },
    'buy_car': {
      'fr': 'Acheter une voiture',
      'en': 'Buy a car',
      'ar': 'شراء سيارة',
    },
    'passport_renewal': {
      'fr': 'Renouvellement passeport',
      'en': 'Passport renewal',
      'ar': 'تجديد جواز السفر',
    },
    'register_company': {
      'fr': "Créer une entreprise",
      'en': 'Register a company',
      'ar': 'تسجيل شركة',
    },
    'loading': {
      'fr': 'Chargement...',
      'en': 'Loading...',
      'ar': 'جار التحميل...',
    },
    'error_generic': {
      'fr': 'Une erreur est survenue.',
      'en': 'An error occurred.',
      'ar': 'حدث خطأ.',
    },
    'retry': {
      'fr': 'Réessayer',
      'en': 'Retry',
      'ar': 'إعادة المحاولة',
    },
    // ── Enterprise popular prompts ──────────────────────────────────
    'tax_registration': {
      'fr': 'Déclaration fiscale',
      'en': 'Tax registration',
      'ar': 'التسجيل الضريبي',
    },
    'business_bank_account': {
      'fr': 'Compte bancaire pro',
      'en': 'Business bank account',
      'ar': 'حساب بنكي تجاري',
    },
    'commercial_register': {
      'fr': 'Registre de commerce',
      'en': 'Commercial register',
      'ar': 'السجل التجاري',
    },
    'rne_registration': {
      'fr': 'Inscription RNE',
      'en': 'RNE registration',
      'ar': 'تسجيل في السجل الوطني',
    },
    // ── Individual procedure names ──────────────────────────────────
    'marriage_certificate': {
      'fr': 'Acte de mariage',
      'en': 'Marriage certificate',
      'ar': 'عقد زواج',
    },
    'national_id_card': {
      'fr': 'Carte d\'identité (CIN)',
      'en': 'National ID card',
      'ar': 'بطاقة التعريف الوطنية',
    },
    'birth_certificate': {
      'fr': 'Acte de naissance',
      'en': 'Birth certificate',
      'ar': 'شهادة الميلاد',
    },
    'driving_license': {
      'fr': 'Permis de conduire',
      'en': 'Driving license',
      'ar': 'رخصة القيادة',
    },
    // ── Enterprise section title ────────────────────────────────────
    'popular_enterprise': {
      'fr': 'Populaires pour entreprises',
      'en': 'Popular for businesses',
      'ar': 'الأكثر شيوعاً للشركات',
    },
    'popular_enterprise_subtitle': {
      'fr': 'Démarches fréquentes pour les entreprises.',
      'en': 'Common procedures businesses are looking for.',
      'ar': 'الإجراءات الشائعة التي تبحث عنها المؤسسات.',
    },
  };

  /// Get a translated string by key and locale.
  /// Falls back to French if the locale or key is missing.
  static String get(String key, String locale) {
    return _strings[key]?[locale] ?? _strings[key]?['fr'] ?? key;
  }
}
