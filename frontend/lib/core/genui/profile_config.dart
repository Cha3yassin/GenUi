import 'package:flutter/material.dart';

import '../locale/app_strings.dart';
import '../theme/app_theme.dart';

enum ProfileType { individual, enterprise }

ProfileType profileFromRole(String? role) {
  return role == 'enterprise' ? ProfileType.enterprise : ProfileType.individual;
}

String profileRole(ProfileType profile) {
  return profile == ProfileType.enterprise ? 'enterprise' : 'individual';
}

String profileLabel(ProfileType profile, String locale) {
  return AppStrings.get(
    profile == ProfileType.enterprise ? 'enterprise' : 'individual',
    locale,
  );
}

String _localized(Map<String, String> values, String locale) {
  return values[locale] ?? values['fr'] ?? values.values.first;
}

class ProfileContent {
  const ProfileContent({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.recommendationsTitle,
    required this.recommendationsSubtitle,
    required this.categoriesTitle,
    required this.categoriesSubtitle,
    required this.searchHint,
    required this.searchTitle,
    required this.searchSubtitle,
    required this.searchSuggestionsTitle,
    required this.searchSuggestionsSubtitle,
    required this.emptyTitle,
    required this.emptyBody,
    required this.trustTitle,
    required this.trustBody,
  });

  final Map<String, String> badge;
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final Map<String, String> recommendationsTitle;
  final Map<String, String> recommendationsSubtitle;
  final Map<String, String> categoriesTitle;
  final Map<String, String> categoriesSubtitle;
  final Map<String, String> searchHint;
  final Map<String, String> searchTitle;
  final Map<String, String> searchSubtitle;
  final Map<String, String> searchSuggestionsTitle;
  final Map<String, String> searchSuggestionsSubtitle;
  final Map<String, String> emptyTitle;
  final Map<String, String> emptyBody;
  final Map<String, String> trustTitle;
  final Map<String, String> trustBody;

  String badgeText(String locale) => _localized(badge, locale);
  String titleText(String locale) => _localized(title, locale);
  String subtitleText(String locale) => _localized(subtitle, locale);
  String recommendationsTitleText(String locale) =>
      _localized(recommendationsTitle, locale);
  String recommendationsSubtitleText(String locale) =>
      _localized(recommendationsSubtitle, locale);
  String categoriesTitleText(String locale) =>
      _localized(categoriesTitle, locale);
  String categoriesSubtitleText(String locale) =>
      _localized(categoriesSubtitle, locale);
  String searchHintText(String locale) => _localized(searchHint, locale);
  String searchTitleText(String locale) => _localized(searchTitle, locale);
  String searchSubtitleText(String locale) =>
      _localized(searchSubtitle, locale);
  String searchSuggestionsTitleText(String locale) =>
      _localized(searchSuggestionsTitle, locale);
  String searchSuggestionsSubtitleText(String locale) =>
      _localized(searchSuggestionsSubtitle, locale);
  String emptyTitleText(String locale) => _localized(emptyTitle, locale);
  String emptyBodyText(String locale) => _localized(emptyBody, locale);
  String trustTitleText(String locale) => _localized(trustTitle, locale);
  String trustBodyText(String locale) => _localized(trustBody, locale);
}

class ProfileThemeData {
  const ProfileThemeData({
    required this.accent,
    required this.secondaryAccent,
    required this.professionalAccent,
    required this.successAccent,
    required this.surfaceTint,
    required this.borderTint,
    required this.badgeColor,
    required this.pageBackground,
    required this.heroForeground,
    required this.heroMutedForeground,
    required this.heroGradient,
  });

  final Color accent;
  final Color secondaryAccent;
  final Color professionalAccent;
  final Color successAccent;
  final Color surfaceTint;
  final Color borderTint;
  final Color badgeColor;
  final Color pageBackground;
  final Color heroForeground;
  final Color heroMutedForeground;
  final List<Color> heroGradient;
}

enum LayoutDensity { comfortable, compact }

enum HeroVariant { personal, businessDashboard }

enum CategoryCardVariant { soft, structured }

enum PrioritySectionVariant { chips, businessCards }

enum SearchVariant { personal, professional }

class ProfileUiVariant {
  const ProfileUiVariant({
    required this.layoutDensity,
    required this.heroVariant,
    required this.categoryCardVariant,
    required this.prioritySectionVariant,
    required this.searchVariant,
    required this.cardRadius,
    required this.cardPadding,
  });

  final LayoutDensity layoutDensity;
  final HeroVariant heroVariant;
  final CategoryCardVariant categoryCardVariant;
  final PrioritySectionVariant prioritySectionVariant;
  final SearchVariant searchVariant;
  final double cardRadius;
  final EdgeInsets cardPadding;
}

class ProfileQuickFilter {
  const ProfileQuickFilter({
    required this.label,
    required this.query,
    required this.icon,
  });

  final String label;
  final String query;
  final IconData icon;
}

const _individualContent = ProfileContent(
  badge: {
    'fr': 'Parcours citoyen',
    'en': 'Citizen flow',
    'ar': 'مسار المواطن',
  },
  title: {
    'fr': 'Vos demarches personnelles.',
    'en': 'Your personal procedures, sorted by priority.',
    'ar': 'إجراءاتك الشخصية مرتبة حسب الأولوية.',
  },
  subtitle: {
    'fr':
        'Un espace doux et accessible pour gerer l identite, la residence, les documents personnels et la protection sociale.',
    'en':
        'Move faster through everyday paperwork: identity, passport, residence, social coverage, and vehicles.',
    'ar':
        'أنجز معاملاتك اليومية أسرع: الهوية، جواز السفر، السكن، التغطية الاجتماعية، والمركبات.',
  },
  recommendationsTitle: {
    'fr': 'A faire en premier',
    'en': 'Start here',
    'ar': 'ابدأ من هنا',
  },
  recommendationsSubtitle: {
    'fr': 'Des procedures utiles pour une personne physique.',
    'en': 'Useful procedures for an individual account.',
    'ar': 'إجراءات مفيدة لحساب فردي.',
  },
  categoriesTitle: {
    'fr': 'Espaces citoyens prioritaires',
    'en': 'Most useful categories for you',
    'ar': 'الفئات الأكثر فائدة لك',
  },
  categoriesSubtitle: {
    'fr':
        'Les categories du quotidien sont mises en avant avec une presentation plus simple et rassurante.',
    'en':
        'Citizen-focused areas rise to the top while the rest stay available.',
    'ar': 'يتم إبراز المجالات الموجهة للمواطن مع الإبقاء على باقي الفئات متاحة.',
  },
  searchHint: {
    'fr': 'Rechercher une procedure personnelle : CIN, passeport, residence...',
    'en': 'Search a personal procedure: ID card, passport, residence...',
    'ar': 'ابحث عن إجراء شخصي: بطاقة هوية، جواز سفر، سكن...',
  },
  searchTitle: {
    'fr': 'Recherche personnelle',
    'en': 'Personal search',
    'ar': 'بحث شخصي',
  },
  searchSubtitle: {
    'fr':
        'Des suggestions orientees citoyen et des resultats reclasses pour vous.',
    'en': 'Citizen-oriented suggestions and profile-aware ranking.',
    'ar': 'اقتراحات موجهة للمواطن ونتائج مرتبة حسب ملفك.',
  },
  searchSuggestionsTitle: {
    'fr': 'Suggestions citoyennes',
    'en': 'Citizen suggestions',
    'ar': 'اقتراحات للمواطن',
  },
  searchSuggestionsSubtitle: {
    'fr': 'Commencez par une demande du quotidien.',
    'en': 'Start with an everyday request.',
    'ar': 'ابدأ بطلب من معاملاتك اليومية.',
  },
  emptyTitle: {
    'fr': 'Aucun resultat adapte',
    'en': 'No relevant result',
    'ar': 'لا توجد نتيجة مناسبة',
  },
  emptyBody: {
    'fr':
        'Essayez une demande personnelle plus large ou parcourez les categories recommandees.',
    'en':
        'Try a broader personal request or browse the recommended categories.',
    'ar': 'جرّب طلبًا شخصيًا أوسع أو تصفح الفئات المقترحة.',
  },
  trustTitle: {
    'fr': 'Assistant pour vos papiers du quotidien',
    'en': 'Assistant for everyday paperwork',
    'ar': 'مساعد لمعاملاتك اليومية',
  },
  trustBody: {
    'fr':
        'L interface vous guide d abord vers les demarches citoyennes les plus frequentes, avec un parcours simple et rassurant.',
    'en':
        'The interface guides you first toward the most common citizen procedures, with a simple and reassuring flow.',
    'ar':
        'توجّهك الواجهة أولاً نحو أكثر الإجراءات شيوعًا للمواطن بطريقة بسيطة ومطمئنة.',
  },
);

const _enterpriseContent = ProfileContent(
  badge: {
    'fr': 'Espace entreprise',
    'en': 'Business cockpit',
    'ar': 'فضاء المؤسسة',
  },
  title: {
    'fr': 'Tableau de bord entreprise',
    'en': 'Your business obligations, organized like a dashboard.',
    'ar': 'التزامات شركتك مرتبة كلوحة متابعة.',
  },
  subtitle: {
    'fr':
        'Gerez vos obligations administratives, fiscales et sociales depuis un tableau de bord structure.',
    'en':
        'Bring creation, tax, registry, CNSS, and management procedures forward with a more structured experience.',
    'ar':
        'تابع إجراءات التأسيس والضرائب والسجل وCNSS ضمن تجربة أكثر تنظيمًا.',
  },
  recommendationsTitle: {
    'fr': 'Actions administratives prioritaires',
    'en': 'Business priorities',
    'ar': 'أولويات المؤسسة',
  },
  recommendationsSubtitle: {
    'fr':
        'Des blocs de travail clairs pour la creation, la fiscalite et le social.',
    'en': 'The most useful procedures to launch or manage a company.',
    'ar': 'أهم الإجراءات لإطلاق الشركة أو إدارتها.',
  },
  categoriesTitle: {
    'fr': 'Piliers de conformite',
    'en': 'Strategic areas',
    'ar': 'محاور استراتيجية',
  },
  categoriesSubtitle: {
    'fr':
        'Les domaines business sont presentes avec une hierarchie plus dashboard et une lecture plus dense.',
    'en':
        'Creation, tax, and compliance are prioritized without hiding the rest.',
    'ar': 'يتم إبراز التأسيس والجباية والامتثال دون إخفاء باقي المجالات.',
  },
  searchHint: {
    'fr': 'Rechercher une formalite entreprise : RNE, TVA, patente, CNSS...',
    'en': 'Search a business procedure: RNE, VAT, patent...',
    'ar': 'ابحث عن إجراء للمؤسسة: RNE، TVA، باتينت، CNSS...',
  },
  searchTitle: {
    'fr': 'Recherche entreprise',
    'en': 'Business search',
    'ar': 'بحث المؤسسات',
  },
  searchSubtitle: {
    'fr':
        'Suggestions orientees gestion administrative et resultats classes pour un entrepreneur.',
    'en':
        'Administrative management suggestions and entrepreneur-aware ranking.',
    'ar': 'اقتراحات موجهة للتسيير الإداري ونتائج مرتبة لرواد الأعمال.',
  },
  searchSuggestionsTitle: {
    'fr': 'Filtres rapides entreprise',
    'en': 'Business suggestions',
    'ar': 'اقتراحات للمؤسسة',
  },
  searchSuggestionsSubtitle: {
    'fr': 'Accedez vite aux formalites fiscales, sociales et de registre.',
    'en': 'Start with a key obligation or formal step.',
    'ar': 'ابدأ بالتزام أساسي أو إجراء رسمي مهم.',
  },
  emptyTitle: {
    'fr': 'Aucun resultat prioritaire',
    'en': 'No business-first result',
    'ar': 'لا توجد نتيجة مناسبة للمؤسسة',
  },
  emptyBody: {
    'fr':
        'Essayez un terme comme RNE, TVA, patente ou declaration fiscale pour remonter les bonnes procedures.',
    'en':
        'Try a term such as RNE, VAT, patent, or tax declaration to surface the right procedures.',
    'ar': 'جرّب كلمات مثل RNE أو TVA أو تصريح ضريبي لإظهار الإجراءات المناسبة.',
  },
  trustTitle: {
    'fr': 'Assistant de gestion administrative',
    'en': 'Administrative operations assistant',
    'ar': 'مساعد التسيير الإداري',
  },
  trustBody: {
    'fr':
        'L interface met d abord en avant les formalites de conformite, de registre et de fiscalite pour une lecture plus professionnelle.',
    'en':
        'The interface prioritizes compliance, registry, and taxation procedures for a more professional workflow.',
    'ar': 'تُعطي الواجهة الأولوية لإجراءات الامتثال والسجل والجباية ضمن مسار احترافي.',
  },
);

ProfileContent getProfileContent(ProfileType profile) {
  return profile == ProfileType.enterprise
      ? _enterpriseContent
      : _individualContent;
}

const _individualUiVariant = ProfileUiVariant(
  layoutDensity: LayoutDensity.comfortable,
  heroVariant: HeroVariant.personal,
  categoryCardVariant: CategoryCardVariant.soft,
  prioritySectionVariant: PrioritySectionVariant.chips,
  searchVariant: SearchVariant.personal,
  cardRadius: 26,
  cardPadding: EdgeInsets.all(18),
);

const _enterpriseUiVariant = ProfileUiVariant(
  layoutDensity: LayoutDensity.compact,
  heroVariant: HeroVariant.businessDashboard,
  categoryCardVariant: CategoryCardVariant.structured,
  prioritySectionVariant: PrioritySectionVariant.businessCards,
  searchVariant: SearchVariant.professional,
  cardRadius: 18,
  cardPadding: EdgeInsets.fromLTRB(16, 14, 16, 14),
);

ProfileUiVariant getProfileUiVariant(ProfileType profile) {
  return profile == ProfileType.enterprise
      ? _enterpriseUiVariant
      : _individualUiVariant;
}

String activeProfileTitle(ProfileType profile, String locale) {
  if (profile == ProfileType.enterprise) {
    if (locale == 'ar') return 'وضع المؤسسة مفعّل';
    return locale == 'en' ? 'Business workspace active' : 'Espace entreprise actif';
  }

  if (locale == 'ar') return 'وضع الفرد مفعّل';
  return locale == 'en' ? 'Citizen profile active' : 'Profil citoyen actif';
}

String activeProfileSubtitle(ProfileType profile, String locale) {
  if (profile == ProfileType.enterprise) {
    if (locale == 'ar') return 'شركة / رائد أعمال';
    return locale == 'en' ? 'Company / Entrepreneur' : 'Societe / Entrepreneur';
  }

  if (locale == 'ar') return 'حساب فردي';
  return locale == 'en' ? 'Individual account' : 'Compte individuel';
}

IconData activeProfileIcon(ProfileType profile) {
  return profile == ProfileType.enterprise
      ? Icons.business_center_rounded
      : Icons.person_rounded;
}

List<ProfileQuickFilter> getQuickFilters(ProfileType profile, String locale) {
  if (profile == ProfileType.enterprise) {
    return [
      ProfileQuickFilter(
        label: locale == 'ar' ? 'جباية' : locale == 'en' ? 'Tax' : 'Fiscalite',
        query: 'TVA',
        icon: Icons.calculate_rounded,
      ),
      ProfileQuickFilter(
        label: locale == 'ar' ? 'تأسيس' : locale == 'en' ? 'Creation' : 'Creation',
        query: 'SARL',
        icon: Icons.apartment_rounded,
      ),
      ProfileQuickFilter(
        label: locale == 'ar' ? 'اجتماعي' : locale == 'en' ? 'Social' : 'Social',
        query: 'CNSS',
        icon: Icons.shield_rounded,
      ),
      ProfileQuickFilter(
        label:
            locale == 'ar' ? 'السجل' : locale == 'en' ? 'Registry' : 'Registre',
        query: 'RNE',
        icon: Icons.badge_rounded,
      ),
    ];
  }

  return [
    ProfileQuickFilter(
      label:
          locale == 'ar' ? 'هوية' : locale == 'en' ? 'Identity' : 'Identite',
      query: 'CIN',
      icon: Icons.badge_rounded,
    ),
    ProfileQuickFilter(
      label: locale == 'ar' ? 'سفر' : locale == 'en' ? 'Travel' : 'Voyage',
      query: 'passeport',
      icon: Icons.card_travel_rounded,
    ),
    ProfileQuickFilter(
      label:
          locale == 'ar' ? 'سكن' : locale == 'en' ? 'Residence' : 'Residence',
      query: 'residence',
      icon: Icons.home_rounded,
    ),
  ];
}

ProfileThemeData getThemeByProfile(ProfileType profile) {
  if (profile == ProfileType.enterprise) {
    return const ProfileThemeData(
      accent: Color(0xFF1E2A44),
      secondaryAccent: Color(0xFF2F4B7C),
      professionalAccent: Color(0xFFD6A94A),
      successAccent: Color(0xFF2E7D5B),
      surfaceTint: Color(0xFFEDEFF5),
      borderTint: Color(0xFFD7DEE8),
      badgeColor: Color(0xFFD6A94A),
      pageBackground: Color(0xFFF4F6FA),
      heroForeground: Colors.white,
      heroMutedForeground: Color(0xFFD6DFEE),
      heroGradient: [Color(0xFF172033), Color(0xFF243B63), Color(0xFF2F4B7C)],
    );
  }

  return const ProfileThemeData(
    accent: AppTheme.olive,
    secondaryAccent: AppTheme.terracotta,
    professionalAccent: AppTheme.warmCoral,
    successAccent: AppTheme.olive,
    surfaceTint: Color(0xFFF3F8FF),
    borderTint: Color(0xFFD3E2F4),
    badgeColor: AppTheme.olive,
    pageBackground: AppTheme.sand,
    heroForeground: AppTheme.ink,
    heroMutedForeground: AppTheme.mutedInk,
    heroGradient: [Color(0xFFFFFFFF), Color(0xFFF0F7FF)],
  );
}
