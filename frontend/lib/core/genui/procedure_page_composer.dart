import '../../core/api/language_utils.dart';
import '../../renderer/models/ui_block_model.dart';
import '../../shared/models/procedure_model.dart';
import 'profile_config.dart';

class ProcedurePageComposer {
  const ProcedurePageComposer._();

  static List<UiBlockModel> compose({
    required ProcedureModel procedure,
    required ProfileType profile,
    required String locale,
  }) {
    final sections = _collectSections(procedure.blocks);
    final warningSection = sections.cast<_SemanticSection?>().firstWhere(
          (section) =>
              section?.block.type == 'info_card' &&
              section?.block.data['icon'] == 'shield',
          orElse: () => null,
        );
    final stepperSection = sections.cast<_SemanticSection?>().firstWhere(
          (section) => section?.block.type == 'stepper',
          orElse: () => null,
        );
    final checklistSection = sections.cast<_SemanticSection?>().firstWhere(
          (section) => section?.block.type == 'checklist',
          orElse: () => null,
        );
    final costSection = sections.cast<_SemanticSection?>().firstWhere(
          (section) => section?.block.type == 'cost_table',
          orElse: () => null,
        );
    final officeSection = sections.cast<_SemanticSection?>().firstWhere(
          (section) =>
              section?.block.type == 'info_card' &&
              section?.block.data['icon'] != 'shield',
          orElse: () => null,
        );

    final isArabic = LanguageUtils.isArabic(procedure.summary.title);
    final isEnterprise = profile == ProfileType.enterprise;

    final composed = <UiBlockModel>[
      UiBlockModel(
        type: 'ai_overview',
        data: {
          'profile': profile.name,
          'title': _overviewTitle(locale, isEnterprise, isArabic),
          'summary': _overviewSummary(
            procedure: procedure,
            isEnterprise: isEnterprise,
            isArabic: isArabic,
          ),
          'metrics': [
            {
              'label': _metricLabel('steps', locale, isArabic),
              'value': '${procedure.totalSteps}',
              'tone': 'secondary',
            },
            {
              'label': _metricLabel('cost', locale, isArabic),
              'value': procedure.summary.estimatedCost,
              'tone': 'professional',
            },
            {
              'label': _metricLabel('offices', locale, isArabic),
              'value': '${procedure.summary.officesToVisit}',
              'tone': 'success',
            },
          ],
          'highlights': _buildHighlights(
            procedure: procedure,
            warningSection: warningSection,
            stepperSection: stepperSection,
            checklistSection: checklistSection,
            costSection: costSection,
            officeSection: officeSection,
            locale: locale,
            isEnterprise: isEnterprise,
            isArabic: isArabic,
          ),
        },
      ),
    ];

    final actionCards = _buildActionCards(
      procedure: procedure,
      stepperSection: stepperSection,
      checklistSection: checklistSection,
      costSection: costSection,
      officeSection: officeSection,
      locale: locale,
      isEnterprise: isEnterprise,
      isArabic: isArabic,
    );
    if (actionCards.isNotEmpty) {
      composed.add(
        UiBlockModel(
          type: 'ai_action_grid',
          data: {
            'profile': profile.name,
            'title': _actionGridTitle(locale, isEnterprise, isArabic),
            'subtitle': _actionGridSubtitle(
              locale,
              isEnterprise,
              isArabic,
              actionCards.length,
            ),
            'cards': actionCards,
          },
        ),
      );
    }

    if (warningSection != null) {
      _appendSemanticSection(composed, warningSection);
    }

    final dynamicOrder = _orderSections(
      stepperSection: stepperSection,
      checklistSection: checklistSection,
      costSection: costSection,
      officeSection: officeSection,
      isEnterprise: isEnterprise,
    );

    for (final section in dynamicOrder) {
      _appendSemanticSection(composed, section);
    }

    return composed;
  }

  static List<_SemanticSection> _collectSections(List<UiBlockModel> blocks) {
    final sections = <_SemanticSection>[];
    UiBlockModel? pendingTitle;

    for (final block in blocks) {
      if (block.type == 'section_title') {
        pendingTitle = block;
        continue;
      }

      sections.add(_SemanticSection(titleBlock: pendingTitle, block: block));
      pendingTitle = null;
    }

    return sections;
  }

  static void _appendSemanticSection(
    List<UiBlockModel> target,
    _SemanticSection section,
  ) {
    if (section.titleBlock != null) {
      target.add(section.titleBlock!);
    }
    target.add(section.block);
  }

  static List<_SemanticSection> _orderSections({
    required _SemanticSection? stepperSection,
    required _SemanticSection? checklistSection,
    required _SemanticSection? costSection,
    required _SemanticSection? officeSection,
    required bool isEnterprise,
  }) {
    final ordered = <_SemanticSection>[];

    if (isEnterprise) {
      if (costSection != null) ordered.add(costSection);
      if (stepperSection != null) ordered.add(stepperSection);
      if (checklistSection != null) ordered.add(checklistSection);
      if (officeSection != null) ordered.add(officeSection);
      return ordered;
    }

    if (stepperSection != null) ordered.add(stepperSection);
    if (checklistSection != null) ordered.add(checklistSection);
    if (officeSection != null) ordered.add(officeSection);
    if (costSection != null) ordered.add(costSection);
    return ordered;
  }

  static String _overviewTitle(
      String locale, bool isEnterprise, bool isArabic) {
    if (isArabic) {
      return isEnterprise ? 'ملخص تنفيذي' : 'نظرة سريعة';
    }
    if (locale == 'en') {
      return isEnterprise ? 'Executive Snapshot' : 'Quick Glance';
    }
    return isEnterprise ? 'Synthese executive' : 'Vue d ensemble';
  }

  static String _overviewSummary({
    required ProcedureModel procedure,
    required bool isEnterprise,
    required bool isArabic,
  }) {
    if (isArabic) {
      return isEnterprise
          ? 'تم إنشاء هذا التخطيط تلقائيا حسب عدد الخطوات والوثائق والتكاليف ونقاط التفاعل الإدارية.'
          : 'تم تنظيم هذه الصفحة تلقائيا لاظهار أهم ما تحتاجه قبل بدء الإجراء.';
    }

    return isEnterprise
        ? 'Cette page est composee dynamiquement selon les etapes, les justificatifs, les frais et les points de contact administratifs.'
        : 'Cette page est composee automatiquement pour mettre en avant les informations utiles avant de commencer.';
  }

  static List<String> _buildHighlights({
    required ProcedureModel procedure,
    required _SemanticSection? warningSection,
    required _SemanticSection? stepperSection,
    required _SemanticSection? checklistSection,
    required _SemanticSection? costSection,
    required _SemanticSection? officeSection,
    required String locale,
    required bool isEnterprise,
    required bool isArabic,
  }) {
    final highlights = <String>[];

    if (warningSection != null) {
      highlights.add(
        isArabic
            ? 'تنبيهات قبل البدء'
            : isEnterprise
                ? 'Points de vigilance detectes'
                : 'Conseils avant demarrage',
      );
    }

    if (stepperSection != null) {
      final steps =
          (stepperSection.block.data['steps'] as List<dynamic>? ?? []).length;
      highlights.add(
        isArabic
            ? '$steps خطوات organisees'
            : '$steps ${steps > 1 ? 'etapes structurees' : 'etape structuree'}',
      );
    }

    if (checklistSection != null) {
      final items =
          (checklistSection.block.data['items'] as List<dynamic>? ?? []).length;
      highlights.add(
        isArabic
            ? '$items وثائق مطلوبة'
            : '$items ${isEnterprise ? 'justificatifs a cadrer' : 'documents a prevoir'}',
      );
    }

    if (costSection != null) {
      final fees =
          (costSection.block.data['fees'] as List<dynamic>? ?? []).length;
      highlights.add(
        isArabic
            ? '$fees lignes de frais'
            : '$fees ${isEnterprise ? 'postes de cout' : 'frais estimes'}',
      );
    }

    if (officeSection != null) {
      highlights.add(
        isArabic
            ? 'Point de contact administratif'
            : isEnterprise
                ? 'Point de contact administratif'
                : 'Guichet ou bureau a contacter',
      );
    }

    if (highlights.isEmpty) {
      highlights.add(
        isArabic
            ? 'Composition automatique de la page'
            : 'Composition automatique de la page',
      );
    }

    return highlights;
  }

  static List<Map<String, dynamic>> _buildActionCards({
    required ProcedureModel procedure,
    required _SemanticSection? stepperSection,
    required _SemanticSection? checklistSection,
    required _SemanticSection? costSection,
    required _SemanticSection? officeSection,
    required String locale,
    required bool isEnterprise,
    required bool isArabic,
  }) {
    final cards = <Map<String, dynamic>>[];

    if (stepperSection != null) {
      final steps = (stepperSection.block.data['steps'] as List<dynamic>? ?? [])
          .cast<Map>();
      final firstTitle = steps.isNotEmpty
          ? steps.first['title']?.toString() ?? ''
          : procedure.summary.title;
      cards.add({
        'title': isArabic
            ? 'Parcours'
            : isEnterprise
                ? 'Workflow'
                : 'Parcours',
        'subtitle': firstTitle,
        'icon': 'route',
        'tone': 'secondary',
        'items': [
          isArabic
              ? '${steps.length} etapes'
              : '${steps.length} ${steps.length > 1 ? 'etapes' : 'etape'}',
        ],
      });
    }

    if (checklistSection != null) {
      final items =
          (checklistSection.block.data['items'] as List<dynamic>? ?? [])
              .take(3);
      cards.add({
        'title': isArabic
            ? 'Documents'
            : isEnterprise
                ? 'Documents'
                : 'Pieces utiles',
        'subtitle': isEnterprise
            ? 'Elements a preparer pour le dossier'
            : 'Pieces a reunir avant la visite',
        'icon': 'folder',
        'tone': 'primary',
        'items': items.map((item) => item['title']?.toString() ?? '').toList(),
      });
    }

    if (costSection != null) {
      final fees =
          (costSection.block.data['fees'] as List<dynamic>? ?? []).take(3);
      cards.add({
        'title': isArabic ? 'Frais' : 'Budget',
        'subtitle': isEnterprise
            ? 'Vue des couts et postes administratifs'
            : 'Montants et frais a prevoir',
        'icon': 'wallet',
        'tone': 'professional',
        'items': fees.map((item) => item['label']?.toString() ?? '').toList(),
      });
    }

    if (officeSection != null) {
      cards.add({
        'title': isArabic ? 'Administration' : 'Guichet',
        'subtitle': officeSection.block.data['title']?.toString() ?? '',
        'icon': 'office',
        'tone': 'success',
        'items': [
          isEnterprise
              ? 'Coordonnees et point de contact'
              : 'Adresse et informations utiles',
        ],
      });
    }

    return cards;
  }

  static String _actionGridTitle(
    String locale,
    bool isEnterprise,
    bool isArabic,
  ) {
    if (isArabic) {
      return isEnterprise ? 'لوحة التكوين الذكي' : 'ملخص ما ستحتاجه';
    }
    if (locale == 'en') {
      return isEnterprise ? 'Adaptive Control Panel' : 'What You Will Need';
    }
    return isEnterprise ? 'Panneau adaptatif' : 'Ce que la page a retenu';
  }

  static String _actionGridSubtitle(
    String locale,
    bool isEnterprise,
    bool isArabic,
    int cardCount,
  ) {
    if (isArabic) {
      return 'تم إنشاء $cardCount blocs selon le contenu disponible.';
    }
    return isEnterprise
        ? '$cardCount blocs ont ete generes selon le contenu de la procedure.'
        : '$cardCount blocs ont ete composes selon les informations disponibles.';
  }

  static String _metricLabel(String key, String locale, bool isArabic) {
    return switch (key) {
      'steps' => isArabic
          ? 'Etapes'
          : locale == 'en'
              ? 'Steps'
              : 'Etapes',
      'cost' => isArabic
          ? 'Cout'
          : locale == 'en'
              ? 'Cost'
              : 'Cout',
      'offices' => isArabic
          ? 'Bureaux'
          : locale == 'en'
              ? 'Offices'
              : 'Bureaux',
      _ => key,
    };
  }
}

class _SemanticSection {
  const _SemanticSection({required this.titleBlock, required this.block});

  final UiBlockModel? titleBlock;
  final UiBlockModel block;
}
