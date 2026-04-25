import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/language_utils.dart';
import '../../core/constants/route_paths.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/async_value_widget.dart';
import '../../renderer/block_renderer.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/widgets/status_badge.dart';

class ProcedureDetailScreen extends ConsumerWidget {
  const ProcedureDetailScreen({required this.slug, this.historyId, super.key});

  final String slug;
  final String? historyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If historyId is provided, load from history; otherwise load live
    final detailValue = historyId != null && historyId!.isNotEmpty
        ? ref.watch(historyDetailProvider(historyId!))
        : ref.watch(procedureDetailProvider(slug));
    final locale = ref.watch(localeProvider);
    final isArabic = locale == 'ar' || LanguageUtils.isArabic(slug);
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.get('procedure', locale),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ),
        body: SafeArea(
          child: AsyncValueWidget<ProcedureModel>(
            value: detailValue,
            data: (procedure) => _ProcedureContent(
              procedure: procedure,
              locale: locale,
            ),
          ),
        ),
      ),
    );
  }
}

/// Main content with stagger animation on page load.
class _ProcedureContent extends StatefulWidget {
  const _ProcedureContent({
    required this.procedure,
    required this.locale,
  });

  final ProcedureModel procedure;
  final String locale;

  @override
  State<_ProcedureContent> createState() => _ProcedureContentState();
}

class _ProcedureContentState extends State<_ProcedureContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _staggeredItem(int index, Widget child) {
    final delay = (index * 80) / 600; // 80ms between items
    final begin = delay.clamp(0.0, 0.9);
    final end = (begin + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int itemIndex = 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _staggeredItem(
            itemIndex++,
            _ProcedureHero(
              procedure: widget.procedure,
              locale: widget.locale,
            )),
        const SizedBox(height: 18),
        _staggeredItem(
            itemIndex++,
            BlockRenderer(
              blocks: widget.procedure.blocks,
              locale: widget.locale,
            )),
        _staggeredItem(
            itemIndex++,
            FilledButton.icon(
              onPressed: () => context.push(
                '${RoutePaths.offices}?stepId=${Uri.encodeComponent(widget.procedure.summary.slug)}',
              ),
              icon: const Icon(Icons.near_me_rounded),
              label: Text(AppStrings.get('find_nearest_office', widget.locale)),
            )),
      ],
    );
  }
}

/// Hero card — no progress bar, no step counter, no circular progress.
class _ProcedureHero extends StatelessWidget {
  const _ProcedureHero({required this.procedure, required this.locale});

  final ProcedureModel procedure;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(label: procedure.summary.categoryLabel),
            const SizedBox(height: 14),
            Text(
              procedure.summary.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              procedure.summary.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryPill(
                  icon: Icons.schedule_rounded,
                  label: procedure.summary.estimatedDuration,
                ),
                _SummaryPill(
                  icon: Icons.payments_rounded,
                  label: procedure.summary.estimatedCost,
                ),
                _SummaryPill(
                  icon: Icons.account_balance_rounded,
                  label:
                      '${procedure.summary.officesToVisit} ${AppStrings.get('offices_label', locale)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
