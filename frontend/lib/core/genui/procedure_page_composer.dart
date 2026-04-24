import '../../renderer/models/ui_block_model.dart';
import '../../shared/models/procedure_model.dart';
import 'profile_config.dart';

class ProcedurePageComposer {
  const ProcedurePageComposer._();

  static List<UiBlockModel> compose({
    required ProcedureModel procedure,
    required ProfileType profile,
    required String locale,
    bool simplified = false,
  }) {
    final sections = _collectSections(procedure.blocks);
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

    final ordered = <_SemanticSection>[
      if (stepperSection != null) stepperSection,
      if (checklistSection != null) checklistSection,
      if (costSection != null) costSection,
      if (officeSection != null) officeSection,
    ];

    return ordered
        .expand((section) => _formatForCitizen(section, locale, simplified))
        .toList();
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

  static List<UiBlockModel> _formatForCitizen(
    _SemanticSection section,
    String locale,
    bool simplified,
  ) {
    final blocks = <UiBlockModel>[];
    final title = _defaultTitleFor(section.block.type, locale);
    if (title != null) {
      blocks.add(
        UiBlockModel(
          type: 'section_title',
          data: {
            'title': title,
            'subtitle': null,
          },
        ),
      );
    } else if (section.titleBlock != null) {
      blocks.add(section.titleBlock!);
    }

    blocks.add(_sanitizeBlock(section.block, simplified));
    return blocks;
  }

  static UiBlockModel _sanitizeBlock(UiBlockModel block, bool simplified) {
    if (block.type == 'stepper' && simplified) {
      final steps = (block.data['steps'] as List<dynamic>? ?? []).map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        map['description'] = _shortText(map['description']?.toString() ?? '');
        return map;
      }).toList();
      return UiBlockModel(type: block.type, data: {...block.data, 'steps': steps});
    }

    if (block.type == 'checklist') {
      final items = (block.data['items'] as List<dynamic>? ?? []).map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        map.remove('note');
        return map;
      }).toList();
      return UiBlockModel(type: block.type, data: {...block.data, 'items': items});
    }

    if (block.type == 'info_card' && simplified) {
      final body = _shortText(block.data['body']?.toString() ?? '');
      return UiBlockModel(type: block.type, data: {...block.data, 'body': body});
    }

    return block;
  }

  static String _shortText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    final sentence = trimmed.split(RegExp(r'[.!؟]')).first.trim();
    return sentence.isEmpty ? trimmed : '$sentence.';
  }

  static String? _defaultTitleFor(String blockType, String locale) {
    final isAr = locale == 'ar';
    final isEn = locale == 'en';
    return switch (blockType) {
      'stepper' => isAr ? 'الخطوات' : isEn ? 'Steps' : 'Étapes',
      'checklist' => isAr ? 'الوثائق المطلوبة' : isEn ? 'Required documents' : 'Documents requis',
      'cost_table' => isAr ? 'الرسوم' : isEn ? 'Cost' : 'Coût',
      'info_card' => isAr ? 'أين أذهب' : isEn ? 'Where to go' : 'Où aller',
      _ => null,
    };
  }
}

class _SemanticSection {
  const _SemanticSection({required this.titleBlock, required this.block});

  final UiBlockModel? titleBlock;
  final UiBlockModel block;
}
