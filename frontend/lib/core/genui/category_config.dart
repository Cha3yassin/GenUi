import 'package:flutter/material.dart';

import '../../shared/models/category_model.dart';
import 'profile_config.dart';

class CategoryUiConfig {
  const CategoryUiConfig({
    required this.id,
    required this.backgroundColor,
    required this.enterpriseLabel,
    required this.priorityByProfile,
  });

  final String id;
  final Color backgroundColor;
  final String enterpriseLabel;
  final Map<ProfileType, int> priorityByProfile;

  int priority(ProfileType profile) => priorityByProfile[profile] ?? 0;
}

const Map<String, CategoryUiConfig> categoryConfigs = {
  'civil_status': CategoryUiConfig(
    id: 'civil_status',
    backgroundColor: Color(0xFFF4F8FF),
    enterpriseLabel: 'Identite',
    priorityByProfile: {
      ProfileType.individual: 100,
      ProfileType.enterprise: 20,
    },
  ),
  'passports_travel': CategoryUiConfig(
    id: 'passports_travel',
    backgroundColor: Color(0xFFF2F7FF),
    enterpriseLabel: 'Mobilite',
    priorityByProfile: {
      ProfileType.individual: 94,
      ProfileType.enterprise: 28,
    },
  ),
  'residence': CategoryUiConfig(
    id: 'residence',
    backgroundColor: Color(0xFFF3F8FC),
    enterpriseLabel: 'Adresse',
    priorityByProfile: {
      ProfileType.individual: 88,
      ProfileType.enterprise: 24,
    },
  ),
  'social_security': CategoryUiConfig(
    id: 'social_security',
    backgroundColor: Color(0xFFF1F7FB),
    enterpriseLabel: 'Social',
    priorityByProfile: {
      ProfileType.individual: 82,
      ProfileType.enterprise: 86,
    },
  ),
  'vehicles': CategoryUiConfig(
    id: 'vehicles',
    backgroundColor: Color(0xFFF4F7FD),
    enterpriseLabel: 'Mobilite',
    priorityByProfile: {
      ProfileType.individual: 80,
      ProfileType.enterprise: 30,
    },
  ),
  'business': CategoryUiConfig(
    id: 'business',
    backgroundColor: Color(0xFFF0F4FC),
    enterpriseLabel: 'Registre',
    priorityByProfile: {
      ProfileType.individual: 26,
      ProfileType.enterprise: 100,
    },
  ),
  'taxation': CategoryUiConfig(
    id: 'taxation',
    backgroundColor: Color(0xFFEFF4FA),
    enterpriseLabel: 'Fiscal',
    priorityByProfile: {
      ProfileType.individual: 18,
      ProfileType.enterprise: 94,
    },
  ),
  'property': CategoryUiConfig(
    id: 'property',
    backgroundColor: Color(0xFFF5F8FD),
    enterpriseLabel: 'Juridique',
    priorityByProfile: {
      ProfileType.individual: 46,
      ProfileType.enterprise: 60,
    },
  ),
};

CategoryUiConfig getCategoryStyle(String categoryId) {
  return categoryConfigs[categoryId] ??
      const CategoryUiConfig(
        id: 'default',
        backgroundColor: Color(0xFFFFFFFF),
        enterpriseLabel: 'Gestion',
        priorityByProfile: {
          ProfileType.individual: 10,
          ProfileType.enterprise: 10,
        },
      );
}

String getCategoryEnterpriseLabel(String categoryId) {
  return getCategoryStyle(categoryId).enterpriseLabel;
}

List<CategoryModel> getCategoriesForProfile(
  ProfileType profileType,
  List<CategoryModel> categories,
) {
  final sorted = [...categories];
  sorted.sort((a, b) {
    final aPriority = getCategoryStyle(a.id).priority(profileType);
    final bPriority = getCategoryStyle(b.id).priority(profileType);
    if (aPriority != bPriority) {
      return bPriority.compareTo(aPriority);
    }
    return a.nameFr.compareTo(b.nameFr);
  });
  return sorted;
}
