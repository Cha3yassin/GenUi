import 'package:flutter/material.dart';

import 'models/ui_block_model.dart';
import 'widgets/checklist_block_widget.dart';
import 'widgets/cost_table_block_widget.dart';
import 'widgets/faq_list_block_widget.dart';
import 'widgets/info_card_block_widget.dart';
import 'widgets/office_list_block_widget.dart';
import 'widgets/office_map_placeholder_block_widget.dart';
import 'widgets/section_title_block_widget.dart';
import 'widgets/stepper_block_widget.dart';

class BlockRenderer extends StatefulWidget {
  const BlockRenderer({
    required this.blocks,
    this.locale = 'fr',
    super.key,
  });

  final List<UiBlockModel> blocks;
  final String locale;

  @override
  State<BlockRenderer> createState() => _BlockRendererState();
}

class _BlockRendererState extends State<BlockRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 400 + (widget.blocks.length * 80),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = 400 + (widget.blocks.length * 80);

    return Column(
      children: [
        for (int i = 0; i < widget.blocks.length; i++) ...[
          _StaggeredBlock(
            controller: _controller,
            index: i,
            totalDuration: totalDuration,
            child: _buildBlock(widget.blocks[i]),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildBlock(UiBlockModel block) {
    return switch (block.type) {
      'info_card' => InfoCardBlockWidget(data: block.data),
      'stepper' => StepperBlockWidget(data: block.data),
      'checklist' => ChecklistBlockWidget(data: block.data),
      'cost_table' => CostTableBlockWidget(data: block.data, locale: widget.locale),
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

class _StaggeredBlock extends StatelessWidget {
  const _StaggeredBlock({
    required this.controller,
    required this.index,
    required this.totalDuration,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final int totalDuration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index * 80) / totalDuration;
    final begin = delay.clamp(0.0, 0.85);
    final end = (begin + 0.35).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
