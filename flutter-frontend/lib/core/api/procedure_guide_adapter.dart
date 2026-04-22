import '../../renderer/models/ui_block_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import 'app_config.dart';

class ProcedureGuideAdapter {
  /// Converts the backend's ProcedureGuideResponse JSON into Flutter's ProcedureModel
  static ProcedureModel fromJson(Map<String, dynamic> json, {required String slug}) {
    // 1. Extract title (using default language)
    final titleMap = json['title'] as Map<String, dynamic>? ?? {};
    final title = titleMap[AppConfig.defaultLanguage] ?? 
                  titleMap.values.firstOrNull?.toString() ?? 
                  'Procédure Administrative';

    // 2. Build Summary
    final costs = json['costs'] as Map<String, dynamic>? ?? {};
    final totalCost = costs['total']?.toString() ?? '0';
    final currency = costs['currency']?.toString() ?? 'TND';
    final estimatedCost = '$totalCost $currency';

    final steps = json['steps'] as List<dynamic>? ?? [];
    final totalSteps = steps.length;

    final summary = ProcedureSummaryModel(
      id: slug,
      slug: slug,
      title: title.toString(),
      summary: 'Guide généré par l\'IA de Sahil basé sur les informations administratives.',
      categoryId: 'ai-generated',
      categoryLabel: 'Assistant',
      estimatedDuration: 'Variable', // Focus is procedure data, not duration
      estimatedCost: estimatedCost,
      officesToVisit: 1,
    );

    // 3. Build Blocks dynamically based on what Gemini returned
    final blocks = <UiBlockModel>[];

    // Warnings -> Info Card
    final warnings = json['warnings'] as List<dynamic>? ?? [];
    if (warnings.isNotEmpty) {
      blocks.add(
        UiBlockModel(
          type: 'info_card',
          data: {
            'title': 'Avant de commencer',
            'body': warnings.map((e) => '• $e').join('\n'),
            'icon': 'shield', // Mapped to icon in renderer
          },
        ),
      );
    }

    // Steps -> Stepper Block
    if (steps.isNotEmpty) {
      blocks.add(
        const UiBlockModel(
          type: 'section_title',
          data: {
            'title': 'Étapes de la procédure',
            'subtitle': 'Suivez ces indications pour accomplir la démarche.',
          },
        ),
      );
      
      final stepperSteps = steps.map((s) {
        final stepMap = s as Map<String, dynamic>;
        return {
          'id': 'step_${stepMap['number']}',
          'title': stepMap['title']?.toString() ?? '',
          'description': stepMap['description']?.toString() ?? '',
          'officeType': stepMap['location']?.toString() ?? '',
          'isCompleted': false,
          'isCurrent': stepMap['number'] == 1,
        };
      }).toList();

      blocks.add(
        UiBlockModel(
          type: 'stepper',
          data: {'steps': stepperSteps},
        ),
      );
    }

    // Documents -> Checklist Block
    final docs = json['documents'] as List<dynamic>? ?? [];
    if (docs.isNotEmpty) {
      blocks.add(
        const UiBlockModel(
          type: 'section_title',
          data: {
            'title': 'Documents requis',
            'subtitle': 'Assurez-vous de préparer ces pièces justificatives.',
          },
        ),
      );
      
      final checklistItems = docs.map((d) => {'title': d.toString()}).toList();
      blocks.add(
        UiBlockModel(
          type: 'checklist',
          data: {'items': checklistItems},
        ),
      );
    }

    // Cost Breakdown -> Cost Table Block
    final breakdown = costs['breakdown'] as List<dynamic>? ?? [];
    if (breakdown.isNotEmpty) {
      blocks.add(
        const UiBlockModel(
          type: 'section_title',
          data: {
            'title': 'Frais estimés',
            'subtitle': 'Les montants officiels peuvent légèrement varier.',
          },
        ),
      );

      final fees = breakdown.map((b) {
        final bMap = b as Map<String, dynamic>;
        return {
          'label': bMap['label']?.toString() ?? 'Frais administratifs',
          'amount': '${bMap['amount'] ?? 0} $currency',
        };
      }).toList();
      
      blocks.add(
        UiBlockModel(
          type: 'cost_table',
          data: {'fees': fees},
        ),
      );
    }

    // Office Info -> Info Card Block
    final office = json['office'] as Map<String, dynamic>?;
    if (office != null && (office['name'] != null || office['address'] != null)) {
      blocks.add(
        const UiBlockModel(
          type: 'section_title',
          data: {
            'title': 'Administration en charge',
            'subtitle': 'Où s\'adresser.',
          },
        ),
      );
      
      String body = '';
      if (office['address'] != null) body += '📍 ${office['address']}\n';
      if (office['hours'] != null) body += '🕒 ${office['hours']}\n';
      if (office['phone'] != null) body += '📞 ${office['phone']}\n';

      blocks.add(
        UiBlockModel(
          type: 'info_card',
          data: {
            'title': office['name']?.toString() ?? 'Bureau Administratif',
            'body': body.trim().isNotEmpty ? body.trim() : 'Contactez l\'administration locale.',
            'icon': 'account_balance',
          },
        ),
      );
    }

    return ProcedureModel(
      summary: summary,
      currentStep: 1,
      totalSteps: totalSteps,
      blocks: blocks,
    );
  }
}
