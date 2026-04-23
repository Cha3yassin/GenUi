import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/language_utils.dart';
import '../../core/constants/route_paths.dart';
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
    // If historyId is provided, load from history; otherwise generate live
    final detailValue = historyId != null && historyId!.isNotEmpty
        ? ref.watch(historyDetailProvider(historyId!))
        : ref.watch(procedureDetailProvider(slug));
    final isArabic = LanguageUtils.isArabic(slug);
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(title: Text(isArabic ? 'الإجراء' : 'Procedure')),
        body: SafeArea(
          child: AsyncValueWidget<ProcedureModel>(
            value: detailValue,
            data: (procedure) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _ProcedureHero(procedure: procedure, isArabic: isArabic),
                const SizedBox(height: 18),
                BlockRenderer(blocks: procedure.blocks),
                FilledButton.icon(
                  onPressed: () => context.push(
                    '${RoutePaths.offices}?stepId=mutation-dossier',
                  ),
                  icon: const Icon(Icons.near_me_rounded),
                  label: Text(
                      isArabic ? 'اعثر على أقرب مكتب' : 'Find nearest office'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcedureHero extends StatelessWidget {
  const _ProcedureHero({required this.procedure, required this.isArabic});

  final ProcedureModel procedure;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final percent =
        procedure.totalSteps > 0 ? (procedure.progress * 100).round() : 100;

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
                  label: isArabic
                      ? '${procedure.summary.officesToVisit} مكاتب'
                      : '${procedure.summary.officesToVisit} offices',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? 'الخطوة ${procedure.currentStep} من ${procedure.totalSteps} - $percent% مكتمل'
                            : 'Step ${procedure.currentStep} of ${procedure.totalSteps} - $percent% done',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: procedure.progress,
                          minHeight: 9,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: procedure.progress,
                    strokeWidth: 6,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                  ),
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
