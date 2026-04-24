import '../../core/api/language_utils.dart';
import '../../renderer/models/ui_block_model.dart';
import '../../shared/models/procedure_model.dart';
import 'procedure_semantic_theme.dart';
import 'profile_config.dart';

class ProcedurePageComposer {
  const ProcedurePageComposer._();

  static List<UiBlockModel> compose({
    required ProcedureModel procedure,
    required ProfileType profile,
    required String locale,
  }) {
    final semanticTheme = inferProcedureSemanticTheme(
      procedure,
      locale: locale,
    );
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
          'semanticId': semanticTheme.id,
          'semanticLabel': semanticTheme.label,
          'semanticIcon': semanticTheme.icon.codePoint,
          'semanticLayout': semanticTheme.layoutStyle,
          'semanticHint': semanticTheme.summaryHint,
          'title': _overviewTitle(locale, isEnterprise, isArabic),
          'summary': _overviewSummary(
            isEnterprise: isEnterprise,
            isArabic: isArabic,
            semanticTheme: semanticTheme,
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
            warningSection: warningSection,
            stepperSection: stepperSection,
            checklistSection: checklistSection,
            costSection: costSection,
            officeSection: officeSection,
            semanticTheme: semanticTheme,
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
      semanticTheme: semanticTheme,
      isEnterprise: isEnterprise,
      isArabic: isArabic,
    );

    if (actionCards.isNotEmpty) {
      composed.add(
        UiBlockModel(
          type: 'ai_action_grid',
          data: {
            'profile': profile.name,
            'semanticId': semanticTheme.id,
            'semanticLabel': semanticTheme.label,
            'semanticIcon': semanticTheme.icon.codePoint,
            'semanticLayout': semanticTheme.layoutStyle,
            'title': _actionGridTitle(locale, isEnterprise, isArabic),
            'subtitle': _actionGridSubtitle(
              isEnterprise: isEnterprise,
              isArabic: isArabic,
              cardCount: actionCards.length,
              semanticTheme: semanticTheme,
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
      semanticTheme: semanticTheme,
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
    required ProcedureSemanticTheme semanticTheme,
    required bool isEnterprise,
  }) {
    final map = {
      'workflow': stepperSection,
      'documents': checklistSection,
      'budget': costSection,
      'office': officeSection,
    };

    final order = switch (semanticTheme.layoutStyle) {
      'featured_budget' => ['budget', 'workflow', 'documents', 'office'],
      'dossier_first' => ['documents', 'workflow', 'budget', 'office'],
      'compact_workflow' => ['workflow', 'documents', 'office', 'budget'],
      'dashboard_launch' => ['workflow', 'budget', 'documents', 'office'],
      _ => isEnterprise
          ? ['budget', 'workflow', 'documents', 'office']
          : ['workflow', 'documents', 'office', 'budget'],
    };

    return order.map((key) => map[key]).whereType<_SemanticSection>().toList();
  }

  static String _overviewTitle(
    String locale,
    bool isEnterprise,
    bool isArabic,
  ) {
    if (isArabic) {
      return isEnterprise ? 'ملخص تنفيذي' : 'نظرة سريعة';
    }
    if (locale == 'en') {
      return isEnterprise ? 'Executive Snapshot' : 'Quick Glance';
    }
    return isEnterprise ? 'Synthese executive' : 'Vue d ensemble';
  }

  static String _overviewSummary({
    required bool isEnterprise,
    required bool isArabic,
    required ProcedureSemanticTheme semanticTheme,
  }) {
    if (isArabic) {
      return isEnterprise
          ? 'تم إنشاء هذه الصفحة بشكل مختلف حسب نوع الإجراء: ${semanticTheme.label}.'
          : 'تم تنظيم هذه الصفحة حسب طبيعة الإجراء: ${semanticTheme.label}.';
    }

    return isEnterprise
        ? 'Cette page adopte une composition ${semanticTheme.label.toLowerCase()} avec une logique de pilotage adaptee.'
        : 'Cette page adopte une composition ${semanticTheme.label.toLowerCase()} pour mettre en avant les informations utiles.';
  }

  static List<String> _buildHighlights({
    required _SemanticSection? warningSection,
    required _SemanticSection? stepperSection,
    required _SemanticSection? checklistSection,
    required _SemanticSection? costSection,
    required _SemanticSection? officeSection,
    required ProcedureSemanticTheme semanticTheme,
    required bool isEnterprise,
    required bool isArabic,
  }) {
    final highlights = <String>[semanticTheme.label];

    if (warningSection != null) {
      highlights.add(
        isArabic
            ? 'تنبيهات avant action'
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
            ? '$steps etapes'
            : '$steps ${steps > 1 ? 'etapes structurees' : 'etape structuree'}',
      );
    }

    if (checklistSection != null) {
      final items =
          (checklistSection.block.data['items'] as List<dynamic>? ?? []).length;
      highlights.add(
        isArabic
            ? '$items documents'
            : '$items ${isEnterprise ? 'justificatifs a cadrer' : 'documents a prevoir'}',
      );
    }

    if (costSection != null) {
      final fees =
          (costSection.block.data['fees'] as List<dynamic>? ?? []).length;
      highlights.add(
        isArabic
            ? '$fees frais'
            : '$fees ${isEnterprise ? 'postes de cout' : 'frais estimes'}',
      );
    }

    if (officeSection != null) {
      highlights.add(
        isArabic
            ? 'point de contact'
            : isEnterprise
                ? 'Point de contact administratif'
                : 'Guichet ou bureau a contacter',
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
    required ProcedureSemanticTheme semanticTheme,
    required bool isEnterprise,
    required bool isArabic,
  }) {
    final workflowCard = () {
      if (stepperSection == null) return null;
      final steps = (stepperSection.block.data['steps'] as List<dynamic>? ?? [])
          .cast<Map>();
      final firstTitle = steps.isNotEmpty
          ? steps.first['title']?.toString() ?? ''
          : procedure.summary.title;
      return {
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
      };
    }();

    final documentsCard = () {
      if (checklistSection == null) return null;
      final items =
          (checklistSection.block.data['items'] as List<dynamic>? ?? [])
              .take(3);
      return {
        'title': isArabic
            ? 'Documents'
            : semanticTheme.id == 'legal_transfer'
                ? 'Dossier juridique'
                : isEnterprise
                    ? 'Documents'
                    : 'Pieces utiles',
        'subtitle': semanticTheme.id == 'legal_transfer'
            ? 'Pieces contractuelles et justificatifs de cession'
            : isEnterprise
                ? 'Elements a preparer pour le dossier'
                : 'Pieces a reunir avant la visite',
        'icon': 'folder',
        'tone': 'primary',
        'items': items.map((item) => item['title']?.toString() ?? '').toList(),
      };
    }();

    final budgetCard = () {
      if (costSection == null) return null;
      final fees =
          (costSection.block.data['fees'] as List<dynamic>? ?? []).take(3);
      return {
        'title': semanticTheme.id == 'acquisition'
            ? 'Budget d achat'
            : isArabic
                ? 'Frais'
                : 'Budget',
        'subtitle': semanticTheme.id == 'acquisition'
            ? 'Montants d acquisition et de mise en circulation'
            : isEnterprise
                ? 'Vue des couts et postes administratifs'
                : 'Montants et frais a prevoir',
        'icon': 'wallet',
        'tone': 'professional',
        'items': fees.map((item) => item['label']?.toString() ?? '').toList(),
      };
    }();

    final officeCard = () {
      if (officeSection == null) return null;
      return {
        'title': semanticTheme.id == 'acquisition'
            ? 'Fournisseur / guichet'
            : isArabic
                ? 'Administration'
                : 'Guichet',
        'subtitle': officeSection.block.data['title']?.toString() ?? '',
        'icon': 'office',
        'tone': 'success',
        'items': [
          isEnterprise
              ? 'Coordonnees et point de contact'
              : 'Adresse et informations utiles',
        ],
      };
    }();

    final map = {
      'workflow': workflowCard,
      'documents': documentsCard,
      'budget': budgetCard,
      'office': officeCard,
    };

    final order = switch (semanticTheme.layoutStyle) {
      'featured_budget' => ['budget', 'office', 'documents', 'workflow'],
      'dossier_first' => ['documents', 'workflow', 'budget', 'office'],
      'compact_workflow' => ['workflow', 'documents', 'office', 'budget'],
      'dashboard_launch' => ['workflow', 'budget', 'documents', 'office'],
      _ => ['workflow', 'documents', 'budget', 'office'],
    };

    return order
        .map((key) => map[key])
        .whereType<Map<String, dynamic>>()
        .toList();
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

  static String _actionGridSubtitle({
    required bool isEnterprise,
    required bool isArabic,
    required int cardCount,
    required ProcedureSemanticTheme semanticTheme,
  }) {
    if (isArabic) {
      return 'تم إنشاء $cardCount blocs selon le type ${semanticTheme.label}.';
    }
    return isEnterprise
        ? '$cardCount blocs generes avec une logique ${semanticTheme.label.toLowerCase()}.'
        : '$cardCount blocs composes selon le type ${semanticTheme.label.toLowerCase()}.';
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
