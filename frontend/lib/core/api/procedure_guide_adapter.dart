import '../../renderer/models/ui_block_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import 'app_config.dart';

class ProcedureGuideAdapter {
  static ProcedureModel fromJson(
    Map<String, dynamic> json, {
    required String slug,
    String? language,
  }) {
    final lang = language ?? AppConfig.defaultLanguage;
    final labels = _labelsFor(lang);

    final titleMap = json['title'] as Map<String, dynamic>? ?? {};
    final title = titleMap[lang]?.toString() ??
        titleMap[AppConfig.defaultLanguage]?.toString() ??
        titleMap.values.firstOrNull?.toString() ??
        labels.fallbackTitle;

    final costs = json['costs'] as Map<String, dynamic>? ?? {};
    final totalCost = costs['total']?.toString() ?? '0';
    final currency = costs['currency']?.toString() ?? 'TND';
    final estimatedCost = '$totalCost $currency';

    final steps = json['steps'] as List<dynamic>? ?? [];
    final totalSteps = steps.length;

    final summary = ProcedureSummaryModel(
      id: slug,
      slug: slug,
      title: title,
      summary: labels.guideSummary,
      categoryId: 'general',
      categoryLabel: labels.guide,
      estimatedDuration: labels.variable,
      estimatedCost: estimatedCost,
      officesToVisit: 1,
    );

    final blocks = <UiBlockModel>[];

    final warnings = json['warnings'] as List<dynamic>? ?? [];
    if (warnings.isNotEmpty) {
      blocks.add(
        UiBlockModel(
          type: 'info_card',
          data: {
            'title': labels.beforeStart,
            'body': warnings.map((e) => '- $e').join('\n'),
            'icon': 'shield',
          },
        ),
      );
    }

    if (steps.isNotEmpty) {
      blocks.add(
        UiBlockModel(
          type: 'section_title',
          data: {
            'title': labels.stepsTitle,
            'subtitle': labels.stepsSubtitle,
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
          'isCurrent': false,
        };
      }).toList();

      blocks.add(
        UiBlockModel(
          type: 'stepper',
          data: {
            'steps': stepperSteps,
          },
        ),
      );
    }

    final docs = json['documents'] as List<dynamic>? ?? [];
    if (docs.isNotEmpty) {
      blocks.add(
        UiBlockModel(
          type: 'section_title',
          data: {
            'title': labels.documentsTitle,
            'subtitle': labels.documentsSubtitle,
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

    final breakdown = costs['breakdown'] as List<dynamic>? ?? [];
    if (breakdown.isNotEmpty) {
      blocks.add(
        UiBlockModel(
          type: 'section_title',
          data: {
            'title': labels.costsTitle,
            'subtitle': labels.costsSubtitle,
          },
        ),
      );

      final fees = breakdown.map((b) {
        final bMap = b as Map<String, dynamic>;
        return {
          'label': bMap['label']?.toString() ?? labels.adminFees,
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

    final office = json['office'] as Map<String, dynamic>?;
    if (office != null &&
        (office['name'] != null || office['address'] != null)) {
      blocks.add(
        UiBlockModel(
          type: 'section_title',
          data: {
            'title': labels.officeTitle,
            'subtitle': labels.officeSubtitle,
          },
        ),
      );

      String body = '';
      if (office['address'] != null) {
        body += '${labels.address}: ${office['address']}\n';
      }
      if (office['hours'] != null) {
        body += '${labels.hours}: ${office['hours']}\n';
      }
      if (office['phone'] != null) {
        body += '${labels.phone}: ${office['phone']}\n';
      }

      blocks.add(
        UiBlockModel(
          type: 'info_card',
          data: {
            'title': office['name']?.toString() ?? labels.adminOffice,
            'body': body.trim().isNotEmpty
                ? body.trim()
                : labels.contactLocalOffice,
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

  static _ProcedureLabels _labelsFor(String language) {
    if (language == 'ar') {
      return const _ProcedureLabels(
        fallbackTitle: 'إجراء إداري',
        guideSummary:
            'دليل مبني على المعلومات الإدارية الرسمية.',
        guide: 'دليل',
        variable: 'متغير',
        beforeStart: 'قبل أن تبدأ',
        stepsTitle: 'خطوات الإجراء',
        stepsSubtitle: 'اتبع هذه التعليمات لإتمام العملية.',
        documentsTitle: 'الوثائق المطلوبة',
        documentsSubtitle: 'تأكد من تحضير هذه الوثائق.',
        costsTitle: 'الرسوم التقديرية',
        costsSubtitle: 'قد تختلف المبالغ الرسمية قليلا.',
        officeTitle: 'الإدارة المعنية',
        officeSubtitle: 'أين تتوجه.',
        adminFees: 'رسوم إدارية',
        adminOffice: 'مكتب إداري',
        contactLocalOffice: 'اتصل بالإدارة المحلية.',
        address: 'العنوان',
        hours: 'التوقيت',
        phone: 'الهاتف',
      );
    }

    if (language == 'en') {
      return const _ProcedureLabels(
        fallbackTitle: 'Administrative Procedure',
        guideSummary:
            'Guide based on official administrative information.',
        guide: 'Guide',
        variable: 'Variable',
        beforeStart: 'Before you begin',
        stepsTitle: 'Procedure Steps',
        stepsSubtitle: 'Follow these instructions to complete the process.',
        documentsTitle: 'Required Documents',
        documentsSubtitle: 'Make sure to prepare these documents.',
        costsTitle: 'Estimated Fees',
        costsSubtitle: 'Official amounts may vary slightly.',
        officeTitle: 'Responsible Office',
        officeSubtitle: 'Where to go.',
        adminFees: 'Administrative fees',
        adminOffice: 'Administrative Office',
        contactLocalOffice: 'Contact the local administration.',
        address: 'Address',
        hours: 'Hours',
        phone: 'Phone',
      );
    }

    return const _ProcedureLabels(
      fallbackTitle: 'Procédure Administrative',
      guideSummary:
          "Guide basé sur les informations administratives officielles.",
      guide: 'Guide',
      variable: 'Variable',
      beforeStart: 'Avant de commencer',
      stepsTitle: 'Étapes de la procédure',
      stepsSubtitle: 'Suivez ces indications pour accomplir la démarche.',
      documentsTitle: 'Documents requis',
      documentsSubtitle: 'Assurez-vous de préparer ces pièces justificatives.',
      costsTitle: 'Frais estimés',
      costsSubtitle: 'Les montants officiels peuvent légèrement varier.',
      officeTitle: 'Administration en charge',
      officeSubtitle: "Où s'adresser.",
      adminFees: 'Frais administratifs',
      adminOffice: 'Bureau Administratif',
      contactLocalOffice: "Contactez l'administration locale.",
      address: 'Adresse',
      hours: 'Horaires',
      phone: 'Téléphone',
    );
  }
}

class _ProcedureLabels {
  const _ProcedureLabels({
    required this.fallbackTitle,
    required this.guideSummary,
    required this.guide,
    required this.variable,
    required this.beforeStart,
    required this.stepsTitle,
    required this.stepsSubtitle,
    required this.documentsTitle,
    required this.documentsSubtitle,
    required this.costsTitle,
    required this.costsSubtitle,
    required this.officeTitle,
    required this.officeSubtitle,
    required this.adminFees,
    required this.adminOffice,
    required this.contactLocalOffice,
    required this.address,
    required this.hours,
    required this.phone,
  });

  final String fallbackTitle;
  final String guideSummary;
  final String guide;
  final String variable;
  final String beforeStart;
  final String stepsTitle;
  final String stepsSubtitle;
  final String documentsTitle;
  final String documentsSubtitle;
  final String costsTitle;
  final String costsSubtitle;
  final String officeTitle;
  final String officeSubtitle;
  final String adminFees;
  final String adminOffice;
  final String contactLocalOffice;
  final String address;
  final String hours;
  final String phone;
}
