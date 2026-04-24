import 'package:flutter/material.dart';

import 'models/ui_block_model.dart';
import 'widgets/ai_action_grid_block_widget.dart';
import 'widgets/ai_overview_block_widget.dart';
import 'widgets/checklist_block_widget.dart';
import 'widgets/cost_table_block_widget.dart';
import 'widgets/faq_list_block_widget.dart';
import 'widgets/info_card_block_widget.dart';
import 'widgets/office_list_block_widget.dart';
import 'widgets/office_map_placeholder_block_widget.dart';
import 'widgets/section_title_block_widget.dart';
import 'widgets/stepper_block_widget.dart';

class BlockRenderer extends StatelessWidget {
  const BlockRenderer({required this.blocks, super.key});

  final List<UiBlockModel> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final block in blocks) ...[
          _buildBlock(block),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildBlock(UiBlockModel block) {
    return switch (block.type) {
      'ai_overview' => AiOverviewBlockWidget(data: block.data),
      'ai_action_grid' => AiActionGridBlockWidget(data: block.data),
      'info_card' => InfoCardBlockWidget(data: block.data),
      'stepper' => StepperBlockWidget(data: block.data),
      'checklist' => ChecklistBlockWidget(data: block.data),
      'cost_table' => CostTableBlockWidget(data: block.data),
      'office_map_placeholder' => OfficeMapPlaceholderBlockWidget(
          data: block.data,
        ),
      'office_list' => OfficeListBlockWidget(data: block.data),
      'faq_list' => FAQListBlockWidget(data: block.data),
      'section_title' => SectionTitleBlockWidget(data: block.data),
      _ => const SizedBox.shrink(),
    };
  }
}
