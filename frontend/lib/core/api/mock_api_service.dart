import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/history_summary_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import 'api_service.dart';

class MockApiService implements ApiService {
  static const _networkDelay = Duration(milliseconds: 260);

  @override
  Future<List<CategoryModel>> getCategories({String? role}) async {
    await Future<void>.delayed(_networkDelay);
    return _categoriesJson.map(CategoryModel.fromJson).toList();
  }

  @override
  Future<List<ProcedureSummaryModel>> searchProcedures(String query) async {
    await Future<void>.delayed(_networkDelay);
    final normalized = query.trim().toLowerCase();
    final procedures = _procedureSummariesJson
        .map(ProcedureSummaryModel.fromJson)
        .toList();

    if (normalized.isEmpty) {
      return procedures;
    }

    return procedures.where((procedure) {
      final haystack = [
        procedure.title,
        procedure.summary,
        procedure.categoryLabel,
        procedure.slug,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();
  }

  @override
  Future<List<ProcedureSummaryModel>> getProceduresByCategory(
    String categoryId,
  ) async {
    await Future<void>.delayed(_networkDelay);
    return _procedureSummariesJson
        .map(ProcedureSummaryModel.fromJson)
        .where((procedure) => procedure.categoryId == categoryId)
        .toList();
  }

  @override
  Future<ProcedureModel> getProcedureDetail(String slug, {String? role}) async {
    await Future<void>.delayed(_networkDelay);
    final detail =
        _procedureDetailsJson[slug] ?? _procedureDetailsJson.values.first;
    return ProcedureModel.fromJson(detail);
  }

  @override
  Future<List<OfficeModel>> getNearbyOffices({
    String? stepId,
    double? lat,
    double? lng,
  }) async {
    await Future<void>.delayed(_networkDelay);
    return _officesJson.map(OfficeModel.fromJson).toList();
  }

  @override
  Future<List<HistorySummary>> getHistorySummaries(String token) async {
    await Future<void>.delayed(_networkDelay);
    return [];
  }

  @override
  Future<Map<String, dynamic>> getHistoryDetail(String token, String historyId) async {
    await Future<void>.delayed(_networkDelay);
    return {};
  }
}

final List<Map<String, dynamic>> _categoriesJson = [
  {
    'id': 'vehicles',
    'title': 'Vehicles',
    'description': 'Carte grise, vente, permis et taxes.',
    'icon': 'directions_car',
    'accentColor': Colors.redAccent.toARGB32(),
  },
  {
    'id': 'real-estate',
    'title': 'Real Estate',
    'description': 'Achat, location, titres et contrats.',
    'icon': 'home_work',
    'accentColor': Colors.brown.toARGB32(),
  },
  {
    'id': 'business',
    'title': 'Business',
    'description': 'Créer, gérer et déclarer une société.',
    'icon': 'business_center',
    'accentColor': Colors.green.toARGB32(),
  },
  {
    'id': 'civil-status',
    'title': 'Civil Status',
    'description': 'Passeport, état civil et documents officiels.',
    'icon': 'badge',
    'accentColor': Colors.blueGrey.toARGB32(),
  },
];

final List<Map<String, dynamic>> _procedureSummariesJson = [
  {
    'id': 'p1',
    'slug': 'buy-used-car',
    'title': 'Buy a used car',
    'summary':
        'Comprendre les documents, taxes et bureaux pour transférer une voiture d’occasion en Tunisie.',
    'categoryId': 'vehicles',
    'categoryLabel': 'Vehicles',
    'estimatedDuration': '~3 days',
    'estimatedCost': '~150 TND',
    'officesToVisit': 4,
  },
  {
    'id': 'p2',
    'slug': 'passport-renewal',
    'title': 'Passport renewal',
    'summary':
        'Préparer le dossier de renouvellement de passeport tunisien et savoir où le déposer.',
    'categoryId': 'civil-status',
    'categoryLabel': 'Civil Status',
    'estimatedDuration': '7-15 days',
    'estimatedCost': '~80 TND',
    'officesToVisit': 1,
  },
  {
    'id': 'p3',
    'slug': 'register-company',
    'title': 'Register a company',
    'summary':
        'Étapes essentielles pour créer une SARL: nom commercial, statuts, RNE et fiscalité.',
    'categoryId': 'business',
    'categoryLabel': 'Business',
    'estimatedDuration': '5-10 days',
    'estimatedCost': '~350 TND',
    'officesToVisit': 3,
  },
];

final Map<String, Map<String, dynamic>> _procedureDetailsJson = {
  'buy-used-car': {
    'summary': _procedureSummariesJson.first,
    'currentStep': 2,
    'totalSteps': 4,
    'blocks': [
      {
        'type': 'info_card',
        'data': {
          'title': 'Before you start',
          'body':
              'For a used vehicle sale in Tunisia, the safest path is to prepare the buyer and seller documents before visiting the notary and ATTT. Keep original documents with copies.',
          'icon': 'shield',
        },
      },
      {
        'type': 'section_title',
        'data': {
          'title': 'Procedure steps',
          'subtitle': 'Follow these steps in order to avoid repeat visits.',
        },
      },
      {
        'type': 'stepper',
        'data': {
          'steps': [
            {
              'id': 'sale-contract',
              'title': 'Sign purchase contract at notary',
              'description':
                  'Buyer and seller sign a notarized sale contract. Verify CIN numbers, vehicle plate and chassis number.',
              'officeType': 'Notary',
              'isCompleted': true,
            },
            {
              'id': 'transfer-tax',
              'title': 'Pay vehicle transfer tax',
              'description':
                  'Pay required fiscal stamps and transfer tax at a finance office or authorized channel.',
              'officeType': 'Recette des Finances',
              'isCurrent': true,
            },
            {
              'id': 'mutation-dossier',
              'title': 'Submit mutation dossier at ATTT office',
              'description':
                  'Submit the completed dossier to the competent ATTT office for ownership transfer.',
              'officeType': 'ATTT',
            },
            {
              'id': 'collect-gray-card',
              'title': 'Collect new gray card (carte grise)',
              'description':
                  'Return with your receipt or follow the pickup instructions to collect the updated carte grise.',
              'officeType': 'ATTT',
            },
          ],
        },
      },
      {
        'type': 'section_title',
        'data': {
          'title': 'Documents for ATTT dossier',
          'subtitle': 'Checklist for step 3.',
        },
      },
      {
        'type': 'checklist',
        'data': {
          'items': [
            {
              'title': 'CIN buyer + seller',
              'note': 'Bring originals and two copies.',
            },
            {
              'title': 'Original carte grise',
              'note': 'Must match vehicle plate and chassis number.',
            },
            {
              'title': 'Notarized sale contract',
              'note': 'Signed by both parties.',
            },
            {
              'title': 'Tax payment receipt',
              'note': 'Keep the original receipt until collection.',
            },
          ],
        },
      },
      {
        'type': 'section_title',
        'data': {
          'title': 'Estimated fees',
          'subtitle': 'Amounts vary by vehicle and regulation updates.',
        },
      },
      {
        'type': 'cost_table',
        'data': {
          'fees': [
            {
              'label': 'Transfer tax',
              'amount': '80 TND',
              'note': 'Indicative amount.',
            },
            {'label': 'Registration fee', 'amount': '50 TND'},
            {
              'label': 'Misc admin costs',
              'amount': '20 TND',
              'note': 'Copies, stamps and forms.',
            },
          ],
        },
      },
      {
        'type': 'faq_list',
        'data': {
          'faqs': [
            {
              'question': 'Can I submit the dossier without the seller?',
              'answer':
                  'Usually yes after the notarized sale contract is signed, but the office can request additional verification if documents are unclear.',
            },
            {
              'question': 'Do fees change by vehicle type?',
              'answer':
                  'Yes. Fiscal amounts can depend on horsepower, vehicle category and current finance rules. Treat Fbureaucracy estimates as guidance.',
            },
            {
              'question': 'What should I verify before payment?',
              'answer':
                  'Check the vehicle identity, plate number, chassis number, unpaid taxes and that the seller identity matches the carte grise.',
            },
          ],
        },
      },
    ],
  },
  'passport-renewal': {
    'summary': _procedureSummariesJson[1],
    'currentStep': 1,
    'totalSteps': 3,
    'blocks': [
      {
        'type': 'info_card',
        'data': {
          'title': 'Renewing a Tunisian passport',
          'body':
              'Prepare recent identity photos, CIN, old passport and payment stamps before visiting the police district or consular service.',
          'icon': 'passport',
        },
      },
      {
        'type': 'checklist',
        'data': {
          'items': [
            {'title': 'Old passport'},
            {'title': 'CIN copy'},
            {'title': 'Recent identity photos'},
            {'title': 'Tax stamp or payment proof'},
          ],
        },
      },
      {
        'type': 'faq_list',
        'data': {
          'faqs': [
            {
              'question': 'How long does it take?',
              'answer':
                  'Processing usually takes one to two weeks depending on the office and season.',
            },
          ],
        },
      },
    ],
  },
  'register-company': {
    'summary': _procedureSummariesJson[2],
    'currentStep': 1,
    'totalSteps': 5,
    'blocks': [
      {
        'type': 'info_card',
        'data': {
          'title': 'Company registration overview',
          'body':
              'Start by preparing company name, activity, partners, capital and draft statutes before RNE and tax registration.',
          'icon': 'business',
        },
      },
      {
        'type': 'stepper',
        'data': {
          'steps': [
            {
              'id': 'name',
              'title': 'Reserve commercial name',
              'description':
                  'Verify availability and prepare the name request.',
              'officeType': 'RNE',
              'isCurrent': true,
            },
            {
              'id': 'statutes',
              'title': 'Prepare statutes',
              'description': 'Draft and sign the company statutes.',
              'officeType': 'Legal advisor or notary',
            },
            {
              'id': 'rne',
              'title': 'Register with RNE',
              'description':
                  'Submit the creation dossier and obtain registration.',
              'officeType': 'RNE',
            },
          ],
        },
      },
    ],
  },
};

final List<Map<String, dynamic>> _officesJson = [
  {
    'id': 'o1',
    'name': 'ATTT - Tunis Centre',
    'type': 'Vehicle registration office',
    'distance': '1.8 km',
    'workingHours': 'Mon-Fri, 08:30-13:30',
    'isOpen': true,
    'address': 'Rue de Syrie, Tunis',
  },
  {
    'id': 'o2',
    'name': 'ATTT - La Marsa',
    'type': 'Vehicle registration office',
    'distance': '8.4 km',
    'workingHours': 'Mon-Fri, 08:30-13:30',
    'isOpen': false,
    'address': 'La Marsa, Tunis',
  },
  {
    'id': 'o3',
    'name': 'Recette des Finances',
    'type': 'Finance office',
    'distance': '2.3 km',
    'workingHours': 'Mon-Fri, 08:00-14:00',
    'isOpen': true,
    'address': 'Avenue Habib Bourguiba, Tunis',
  },
];
