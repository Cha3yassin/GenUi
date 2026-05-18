/// Simple map-based i18n for the Fbureaucracy app.
/// Supports: fr (French), en (English), ar (Arabic).
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _strings = {
    'app_name': {
      'fr': 'f-idarty',
      'en': 'f-idarty',
      'ar': 'إف إدارتي',
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
          'f-idarty organise les documents, frais et bureaux pour planifier vos visites avec moins d\'incertitude.',
      'en':
          'f-idarty organizes documents, fees and offices so you can plan visits with less uncertainty.',
      'ar':
          'يقوم f-idarty بتنظيم الوثائق والرسوم والمكاتب حتى تتمكن من التخطيط لزياراتك بأقل قدر من عدم اليقين.',
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
    // ── Procedure detail screen ─────────────────────────────────────
    'procedure': {
      'fr': 'Procédure',
      'en': 'Procedure',
      'ar': 'الإجراء',
    },
    'find_nearest_office': {
      'fr': 'Trouver le bureau le plus proche',
      'en': 'Find nearest office',
      'ar': 'اعثر على أقرب مكتب',
    },
    'offices_label': {
      'fr': 'bureaux',
      'en': 'offices',
      'ar': 'مكاتب',
    },
    // ── Search screen ───────────────────────────────────────────────
    'search': {
      'fr': 'Recherche',
      'en': 'Search',
      'ar': 'بحث',
    },
    'suggestions': {
      'fr': 'Suggestions',
      'en': 'Suggestions',
      'ar': 'اقتراحات',
    },
    'suggestions_subtitle': {
      'fr': 'Commencez par une démarche courante.',
      'en': 'Start with a common Tunisian procedure.',
      'ar': 'ابدأ بإجراء شائع.',
    },
    'results': {
      'fr': 'Résultats',
      'en': 'Results',
      'ar': 'النتائج',
    },
    'no_results': {
      'fr':
          'Aucune procédure trouvée. Essayez un mot-clé plus large ou parcourez les catégories.',
      'en':
          'No matching procedure yet. Try a broader keyword or browse categories.',
      'ar': 'لم يتم العثور على إجراء مطابق. حاول بكلمة أوسع أو تصفح الفئات.',
    },
    'search_try': {
      'fr': 'Essayez : acheter voiture, carte grise, passeport',
      'en': 'Try: buy a used car, carte grise, passport',
      'ar': 'جرّب: شراء سيارة، بطاقة رمادية، جواز سفر',
    },
    // ── Login screen ────────────────────────────────────────────────
    'continue_without_account': {
      'fr': 'Continuer sans compte',
      'en': 'Continue without account',
      'ar': 'متابعة بدون حساب',
    },
    'or': {
      'fr': 'ou',
      'en': 'or',
      'ar': 'أو',
    },
    'data_protection': {
      'fr': 'Vos données sont protégées et jamais partagées.',
      'en': 'Your data is protected and never shared with third parties.',
      'ar': 'بياناتك محمية ولن تُشارك مع أي جهة خارجية.',
    },
    // ── Role bottom sheet ───────────────────────────────────────────
    'role_subtitle': {
      'fr': 'Sélectionnez le type de démarches recherchées',
      'en': 'Select the type of procedures you need',
      'ar': 'حدد نوع الإجراءات التي تبحث عنها',
    },
    // ── History drawer ──────────────────────────────────────────────
    'sign_in_for_history': {
      'fr': 'Connectez-vous pour voir l\'historique',
      'en': 'Sign in to view your history',
      'ar': 'سجّل دخولك لرؤية السجل',
    },
    // ── Category titles ─────────────────────────────────────────────
    'cat_civil_status': {
      'fr': 'État Civil',
      'en': 'Civil Status',
      'ar': 'الحالة المدنية',
    },
    'cat_vehicles': {
      'fr': 'Véhicules',
      'en': 'Vehicles',
      'ar': 'المركبات',
    },
    'cat_taxation': {
      'fr': 'Fiscalité',
      'en': 'Taxation',
      'ar': 'الضرائب',
    },
    'cat_residence': {
      'fr': 'Résidence',
      'en': 'Residence',
      'ar': 'الإقامة',
    },
    'cat_passports_travel': {
      'fr': 'Passeports & Voyages',
      'en': 'Passports & Travel',
      'ar': 'جوازات السفر',
    },
    'cat_business': {
      'fr': 'Création d\'entreprise',
      'en': 'Business',
      'ar': 'الأعمال التجارية',
    },
    'cat_social_security': {
      'fr': 'Sécurité Sociale',
      'en': 'Social Security',
      'ar': 'الضمان الاجتماعي',
    },
    'cat_property': {
      'fr': 'Immobilier',
      'en': 'Property',
      'ar': 'العقارات',
    },
    'cat_procedures': {
      'fr': 'Procédures',
      'en': 'Procedures',
      'ar': 'الإجراءات',
    },
    // ── Empty states ────────────────────────────────────────────────
    'no_procedures_in_category': {
      'fr': 'Aucune procédure disponible dans cette catégorie.',
      'en': 'No procedures available in this category yet.',
      'ar': 'لا توجد إجراءات متاحة لهذه الفئة بعد.',
    },
    // ── Search placeholder cycling examples ─────────────────────────
    'search_example_1': {
      'fr': 'Passeport...',
      'en': 'Passport...',
      'ar': 'جواز سفر...',
    },
    'search_example_2': {
      'fr': 'Carte grise...',
      'en': 'Carte grise...',
      'ar': 'بطاقة رمادية...',
    },
    'search_example_3': {
      'fr': 'Acte de naissance...',
      'en': 'Birth certificate...',
      'ar': 'شهادة ميلاد...',
    },
    'search_example_4': {
      'fr': 'CIN...',
      'en': 'ID card...',
      'ar': 'بطاقة هوية...',
    },
    // ── Cost table ──────────────────────────────────────────────────
    'total': {
      'fr': 'Total',
      'en': 'Total',
      'ar': 'المجموع',
    },
    // ── Error fallback ──────────────────────────────────────────────
    'error_fallback': {
      'fr': 'Une erreur est survenue. Veuillez réessayer.',
      'en': 'An error occurred. Please try again.',
      'ar': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
    },
    // ── Suggestion chip labels ──────────────────────────────────────
    'chip_buy_car': {
      'fr': 'acheter une voiture',
      'en': 'buy a used car',
      'ar': 'شراء سيارة',
    },
    'chip_carte_grise': {
      'fr': 'carte grise',
      'en': 'carte grise',
      'ar': 'بطاقة رمادية',
    },
    'chip_passport': {
      'fr': 'passeport',
      'en': 'passport',
      'ar': 'جواز سفر',
    },
    'chip_enterprise': {
      'fr': 'entreprise',
      'en': 'business',
      'ar': 'مؤسسة',
    },
    // ── Enterprise tab ──────────────────────────────────────────────
    'tab_individual': {
      'fr': 'Individuel',
      'en': 'Individual',
      'ar': 'فردي',
    },
    'tab_enterprise': {
      'fr': 'Entreprise / Pro',
      'en': 'Enterprise / Pro',
      'ar': 'مؤسسة / مهني',
    },
    'espace_entreprise': {
      'fr': 'Espace Entreprise',
      'en': 'Enterprise Hub',
      'ar': 'فضاء المؤسسات',
    },
    'espace_entreprise_subtitle': {
      'fr': 'Formalités de registre, fiscalité et CNSS',
      'en': 'Registry formalities, taxation and CNSS',
      'ar': 'إجراءات السجل والضرائب والصندوق الوطني',
    },
    'search_enterprise_hint': {
      'fr': 'Rechercher une formalité : RNE, TVA...',
      'en': 'Search a formality: RNE, VAT...',
      'ar': 'ابحث عن إجراء: RNE، ضريبة...',
    },
    'quick_filters': {
      'fr': 'Filtres rapides',
      'en': 'Quick filters',
      'ar': 'تصفية سريعة',
    },
    'filter_fiscalite': {
      'fr': 'Fiscalité',
      'en': 'Taxation',
      'ar': 'الضرائب',
    },
    'filter_creation': {
      'fr': 'Création',
      'en': 'Creation',
      'ar': 'التأسيس',
    },
    'filter_social': {
      'fr': 'Social',
      'en': 'Social',
      'ar': 'اجتماعي',
    },
    'filter_registre': {
      'fr': 'Registre',
      'en': 'Registry',
      'ar': 'السجل',
    },
    'priority_actions': {
      'fr': 'Actions administratives prioritaires',
      'en': 'Priority administrative actions',
      'ar': 'إجراءات إدارية ذات أولوية',
    },
    'priority_actions_subtitle': {
      'fr': 'Des blocs de travail clairs pour la création, la fiscalité et le social.',
      'en': 'Clear work blocks for creation, taxation and social obligations.',
      'ar': 'كتل عمل واضحة للتأسيس والضرائب والالتزامات الاجتماعية.',
    },
    'action_create_company': {
      'fr': 'Créer ou modifier une société',
      'en': 'Create or modify a company',
      'ar': 'إنشاء أو تعديل شركة',
    },
    'action_create_company_subtitle': {
      'fr': 'Registre, immatriculation et pièces de lancement.',
      'en': 'Registry, registration and launch documents.',
      'ar': 'السجل والتسجيل ووثائق الانطلاق.',
    },
    'action_fiscal': {
      'fr': 'Obligations fiscales',
      'en': 'Tax obligations',
      'ar': 'الالتزامات الضريبية',
    },
    'action_fiscal_subtitle': {
      'fr': 'Suivi des taxes, déclarations et conformité fiscale.',
      'en': 'Tax tracking, declarations and fiscal compliance.',
      'ar': 'متابعة الضرائب والإقرارات والامتثال الضريبي.',
    },
    'action_social': {
      'fr': 'Obligations sociales',
      'en': 'Social obligations',
      'ar': 'الالتزامات الاجتماعية',
    },
    'action_social_subtitle': {
      'fr': 'Couverture sociale et organismes obligatoires.',
      'en': 'Social coverage and mandatory organizations.',
      'ar': 'التغطية الاجتماعية والهيئات الإلزامية.',
    },
    'sub_sarl': {
      'fr': 'Créer SARL',
      'en': 'Create SARL',
      'ar': 'إنشاء شركة ذ.م.م',
    },
    'sub_rne': {
      'fr': 'Inscription RNE',
      'en': 'RNE Registration',
      'ar': 'تسجيل RNE',
    },
    'sub_patente': {
      'fr': 'Patente',
      'en': 'Patent',
      'ar': 'البراءة',
    },
    'sub_tva': {
      'fr': 'TVA',
      'en': 'VAT',
      'ar': 'ضريبة القيمة المضافة',
    },
    'sub_declaration': {
      'fr': 'Déclaration fiscale',
      'en': 'Tax declaration',
      'ar': 'الإقرار الضريبي',
    },
    'sub_quitus': {
      'fr': 'Quitus fiscal',
      'en': 'Tax clearance',
      'ar': 'إبراء ضريبي',
    },
    'sub_cnss': {
      'fr': 'CNSS',
      'en': 'CNSS',
      'ar': 'الصندوق الوطني للضمان الاجتماعي',
    },
    'sub_cnam': {
      'fr': 'CNAM',
      'en': 'CNAM',
      'ar': 'الصندوق الوطني للتأمين على المرض',
    },
    'sub_retraite': {
      'fr': 'Retraite',
      'en': 'Retirement',
      'ar': 'التقاعد',
    },
    'consult_all': {
      'fr': 'Consulter',
      'en': 'View all',
      'ar': 'عرض الكل',
    },
  };

  /// Get a translated string by key and locale.
  /// Falls back to French if the locale or key is missing.
  static String get(String key, String locale) {
    return _strings[key]?[locale] ?? _strings[key]?['fr'] ?? key;
  }
}
