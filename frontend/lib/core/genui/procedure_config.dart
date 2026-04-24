import '../../core/constants/category_procedures_data.dart';
import '../../shared/models/procedure_summary_model.dart';
import 'profile_config.dart';

class ProcedureUiConfig {
  const ProcedureUiConfig({
    required this.slug,
    required this.categoryId,
    required this.allowedProfiles,
    required this.priorityByProfile,
    required this.tags,
    required this.descriptions,
  });

  final String slug;
  final String categoryId;
  final List<ProfileType> allowedProfiles;
  final Map<ProfileType, int> priorityByProfile;
  final List<String> tags;
  final Map<ProfileType, String> descriptions;

  int priority(ProfileType profile) => priorityByProfile[profile] ?? 0;
  String description(ProfileType profile) => descriptions[profile] ?? '';
}

const Map<String, ProcedureUiConfig> procedureConfigs = {
  'national-id-card-cin': ProcedureUiConfig(
    slug: 'national-id-card-cin',
    categoryId: 'civil_status',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 100,
      ProfileType.enterprise: 10,
    },
    tags: ['cin', 'carte identite', 'id card', 'citoyen'],
    descriptions: {
      ProfileType.individual:
          'Piece d identite essentielle pour vos demarches.',
      ProfileType.enterprise: 'Reference personnelle utile pour le gerant.',
    },
  ),
  'birth-certificate': ProcedureUiConfig(
    slug: 'birth-certificate',
    categoryId: 'civil_status',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 92,
      ProfileType.enterprise: 8,
    },
    tags: ['naissance', 'birth', 'etat civil'],
    descriptions: {
      ProfileType.individual: 'Document d etat civil souvent demande.',
      ProfileType.enterprise: 'Peu prioritaire pour un parcours entreprise.',
    },
  ),
  'marriage-certificate': ProcedureUiConfig(
    slug: 'marriage-certificate',
    categoryId: 'civil_status',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 88,
      ProfileType.enterprise: 8,
    },
    tags: ['mariage', 'marriage', 'famille'],
    descriptions: {
      ProfileType.individual: 'Acte personnel pour vos formalites familiales.',
      ProfileType.enterprise: 'Procedure secondaire pour une entreprise.',
    },
  ),
  'new-passport-tunisia': ProcedureUiConfig(
    slug: 'new-passport-tunisia',
    categoryId: 'passports_travel',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 96,
      ProfileType.enterprise: 18,
    },
    tags: ['passeport', 'passport', 'voyage'],
    descriptions: {
      ProfileType.individual: 'Demarche voyage a garder visible.',
      ProfileType.enterprise: 'Utile surtout pour un dirigeant.',
    },
  ),
  'passport-renewal': ProcedureUiConfig(
    slug: 'passport-renewal',
    categoryId: 'passports_travel',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 94,
      ProfileType.enterprise: 18,
    },
    tags: ['renouvellement', 'passeport', 'passport renewal'],
    descriptions: {
      ProfileType.individual: 'Renouvelez rapidement vos documents de voyage.',
      ProfileType.enterprise:
          'Utile surtout pour les deplacements du dirigeant.',
    },
  ),
  'travel-visa-application': ProcedureUiConfig(
    slug: 'travel-visa-application',
    categoryId: 'passports_travel',
    allowedProfiles: [ProfileType.individual, ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 72,
      ProfileType.enterprise: 40,
    },
    tags: ['visa', 'voyage', 'travel'],
    descriptions: {
      ProfileType.individual: 'Preparation d un voyage personnel.',
      ProfileType.enterprise: 'Preparation d un deplacement professionnel.',
    },
  ),
  'change-of-address-tunisia': ProcedureUiConfig(
    slug: 'change-of-address-tunisia',
    categoryId: 'residence',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 84,
      ProfileType.enterprise: 18,
    },
    tags: ['adresse', 'residence', 'change address'],
    descriptions: {
      ProfileType.individual: 'Mettre a jour votre situation residentielle.',
      ProfileType.enterprise: 'Faible priorite pour un profil societe.',
    },
  ),
  'residency-certificate-tunisia': ProcedureUiConfig(
    slug: 'residency-certificate-tunisia',
    categoryId: 'residence',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 82,
      ProfileType.enterprise: 18,
    },
    tags: ['certificat residence', 'residence', 'adresse'],
    descriptions: {
      ProfileType.individual: 'Justificatif classique de residence.',
      ProfileType.enterprise: 'Faible priorite pour un profil societe.',
    },
  ),
  'driving-license-tunisia': ProcedureUiConfig(
    slug: 'driving-license-tunisia',
    categoryId: 'vehicles',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 80,
      ProfileType.enterprise: 16,
    },
    tags: ['permis', 'driving', 'license'],
    descriptions: {
      ProfileType.individual: 'Acces rapide aux demarches de conduite.',
      ProfileType.enterprise: 'Peu prioritaire sauf pour flotte interne.',
    },
  ),
  'buy-used-car': ProcedureUiConfig(
    slug: 'buy-used-car',
    categoryId: 'vehicles',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 74,
      ProfileType.enterprise: 22,
    },
    tags: ['achat voiture', 'car', 'vehicule'],
    descriptions: {
      ProfileType.individual: 'Procedure frequente pour un achat personnel.',
      ProfileType.enterprise: 'Utile ponctuellement pour une flotte.',
    },
  ),
  'carte-grise-transfer': ProcedureUiConfig(
    slug: 'carte-grise-transfer',
    categoryId: 'vehicles',
    allowedProfiles: [ProfileType.individual, ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 78,
      ProfileType.enterprise: 46,
    },
    tags: ['carte grise', 'vehicule', 'registration'],
    descriptions: {
      ProfileType.individual: 'Formalite vehicule tres courante.',
      ProfileType.enterprise: 'Gestion utile pour un parc auto.',
    },
  ),
  'cnam-enrollment-tunisia': ProcedureUiConfig(
    slug: 'cnam-enrollment-tunisia',
    categoryId: 'social_security',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 86,
      ProfileType.enterprise: 26,
    },
    tags: ['cnam', 'sante', 'assurance'],
    descriptions: {
      ProfileType.individual: 'Protection sociale personnelle.',
      ProfileType.enterprise: 'Secondaire pour un profil entreprise.',
    },
  ),
  'retirement-pension-tunisia': ProcedureUiConfig(
    slug: 'retirement-pension-tunisia',
    categoryId: 'social_security',
    allowedProfiles: [ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 76,
      ProfileType.enterprise: 16,
    },
    tags: ['retraite', 'pension'],
    descriptions: {
      ProfileType.individual: 'Accompagnement sur la retraite.',
      ProfileType.enterprise: 'Secondaire pour un profil entreprise.',
    },
  ),
  'register-company-sarl-tunisia': ProcedureUiConfig(
    slug: 'register-company-sarl-tunisia',
    categoryId: 'business',
    allowedProfiles: [ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 20,
      ProfileType.enterprise: 100,
    },
    tags: ['sarl', 'creation entreprise', 'register company'],
    descriptions: {
      ProfileType.individual: 'Visible mais non prioritaire pour un citoyen.',
      ProfileType.enterprise: 'Point de depart pour lancer une societe.',
    },
  ),
  'rne-registration-tunisia': ProcedureUiConfig(
    slug: 'rne-registration-tunisia',
    categoryId: 'business',
    allowedProfiles: [ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 18,
      ProfileType.enterprise: 96,
    },
    tags: ['rne', 'registre national entreprises', 'registre'],
    descriptions: {
      ProfileType.individual: 'Secondaire pour un usage personnel.',
      ProfileType.enterprise: 'Formalite cle pour immatriculer une societe.',
    },
  ),
  'patent-registration-tunisia': ProcedureUiConfig(
    slug: 'patent-registration-tunisia',
    categoryId: 'business',
    allowedProfiles: [ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 16,
      ProfileType.enterprise: 90,
    },
    tags: ['patente', 'patent', 'activite'],
    descriptions: {
      ProfileType.individual: 'Secondaire pour un usage personnel.',
      ProfileType.enterprise: 'Procedure recurrente de gestion d activite.',
    },
  ),
  'tax-declaration-tunisia': ProcedureUiConfig(
    slug: 'tax-declaration-tunisia',
    categoryId: 'taxation',
    allowedProfiles: [ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 24,
      ProfileType.enterprise: 94,
    },
    tags: ['declaration fiscale', 'tax', 'fiscalite'],
    descriptions: {
      ProfileType.individual: 'Faible priorite en parcours personnel.',
      ProfileType.enterprise: 'Obligation centrale pour piloter la fiscalite.',
    },
  ),
  'tva-registration-tunisia': ProcedureUiConfig(
    slug: 'tva-registration-tunisia',
    categoryId: 'taxation',
    allowedProfiles: [ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 14,
      ProfileType.enterprise: 92,
    },
    tags: ['tva', 'vat', 'fiscalite'],
    descriptions: {
      ProfileType.individual: 'Peu utile pour un particulier.',
      ProfileType.enterprise: 'Formalite cle pour la gestion TVA.',
    },
  ),
  'quitus-fiscal-tax-clearance-tunisia': ProcedureUiConfig(
    slug: 'quitus-fiscal-tax-clearance-tunisia',
    categoryId: 'taxation',
    allowedProfiles: [ProfileType.enterprise],
    priorityByProfile: {
      ProfileType.individual: 18,
      ProfileType.enterprise: 88,
    },
    tags: ['quitus fiscal', 'tax clearance'],
    descriptions: {
      ProfileType.individual: 'Secondaire pour un parcours citoyen.',
      ProfileType.enterprise:
          'Document important pour vos dossiers de conformite.',
    },
  ),
  'cnss-registration-tunisia': ProcedureUiConfig(
    slug: 'cnss-registration-tunisia',
    categoryId: 'social_security',
    allowedProfiles: [ProfileType.enterprise, ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 54,
      ProfileType.enterprise: 86,
    },
    tags: ['cnss', 'social', 'entreprise'],
    descriptions: {
      ProfileType.individual: 'Peut concerner votre couverture sociale.',
      ProfileType.enterprise:
          'Procedure cle pour la gestion sociale de l entreprise.',
    },
  ),
  'rental-contract-registration-tunisia': ProcedureUiConfig(
    slug: 'rental-contract-registration-tunisia',
    categoryId: 'property',
    allowedProfiles: [ProfileType.enterprise, ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 44,
      ProfileType.enterprise: 62,
    },
    tags: ['contrat location', 'bail', 'location professionnelle'],
    descriptions: {
      ProfileType.individual: 'Demarche immobiliere ponctuelle.',
      ProfileType.enterprise:
          'Utile pour un local ou une implantation professionnelle.',
    },
  ),
  'buy-property-tunisia': ProcedureUiConfig(
    slug: 'buy-property-tunisia',
    categoryId: 'property',
    allowedProfiles: [ProfileType.enterprise, ProfileType.individual],
    priorityByProfile: {
      ProfileType.individual: 40,
      ProfileType.enterprise: 58,
    },
    tags: ['achat immobilier', 'property', 'local professionnel'],
    descriptions: {
      ProfileType.individual: 'Projet immobilier personnel.',
      ProfileType.enterprise: 'Achat immobilier professionnel ou implantation.',
    },
  ),
};

ProcedureUiConfig? getProcedureConfig(String slug) => procedureConfigs[slug];

List<ProcedureUiConfig> getProceduresForProfile(ProfileType profileType) {
  final procedures = procedureConfigs.values
      .where((procedure) => procedure.allowedProfiles.contains(profileType))
      .toList();
  procedures.sort(
    (a, b) => b.priority(profileType).compareTo(a.priority(profileType)),
  );
  return procedures;
}

List<String> getRecommendedProcedures(ProfileType profileType) {
  return getProceduresForProfile(profileType)
      .take(6)
      .map((procedure) => procedure.slug)
      .toList();
}

List<Map<String, dynamic>> prioritizeProcedureEntries(
  List<Map<String, dynamic>> procedures,
  ProfileType profileType,
) {
  final sorted = [...procedures];
  sorted.sort((a, b) {
    final aSlug = a['slug'] as String? ?? '';
    final bSlug = b['slug'] as String? ?? '';
    final aPriority = getProcedureConfig(aSlug)?.priority(profileType) ?? 0;
    final bPriority = getProcedureConfig(bSlug)?.priority(profileType) ?? 0;
    if (aPriority != bPriority) {
      return bPriority.compareTo(aPriority);
    }
    final aName = CategoryProceduresData.localizedName(a, 'fr');
    final bName = CategoryProceduresData.localizedName(b, 'fr');
    return aName.compareTo(bName);
  });
  return sorted;
}

List<ProcedureSummaryModel> searchProcedures(
  List<ProcedureSummaryModel> results,
  String query,
  ProfileType profileType,
) {
  final normalizedQuery = query.toLowerCase().trim();
  final sorted = [...results];

  int score(ProcedureSummaryModel procedure) {
    final config = getProcedureConfig(procedure.slug);
    var total = config?.priority(profileType) ?? 0;

    final haystacks = [
      procedure.title.toLowerCase(),
      procedure.summary.toLowerCase(),
      procedure.categoryLabel.toLowerCase(),
      procedure.slug.toLowerCase(),
      ...?config?.tags.map((tag) => tag.toLowerCase()),
    ];

    for (final haystack in haystacks) {
      if (normalizedQuery.isNotEmpty && haystack.contains(normalizedQuery)) {
        total += 35;
      }
    }

    if (config != null && config.allowedProfiles.contains(profileType)) {
      total += 10;
    }

    return total;
  }

  sorted.sort((a, b) => score(b).compareTo(score(a)));
  return sorted;
}

String procedureLabel(String slug, String locale) {
  for (final entries in CategoryProceduresData.procedures.values) {
    for (final procedure in entries) {
      if (procedure['slug'] == slug) {
        return CategoryProceduresData.localizedName(procedure, locale);
      }
    }
  }
  return slug.replaceAll('-', ' ');
}
