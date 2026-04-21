import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/constants/route_paths.dart';
import '../../core/utils/async_value_widget.dart';
import '../../renderer/block_renderer.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/widgets/status_badge.dart';

class ProcedureDetailScreen extends ConsumerWidget {
  const ProcedureDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailValue = ref.watch(procedureDetailProvider(slug));

    return Scaffold(
      appBar: AppBar(title: const Text('Procedure')),
      body: SafeArea(
        child: AsyncValueWidget<ProcedureModel>(
          value: detailValue,
          data: (procedure) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _ProcedureHero(procedure: procedure),
              const SizedBox(height: 18),
              BlockRenderer(blocks: procedure.blocks),
              FilledButton.icon(
                onPressed: () => context.push(
                  '${RoutePaths.offices}?stepId=mutation-dossier',
                ),
                icon: const Icon(Icons.near_me_rounded),
                label: const Text('Find nearest office'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcedureHero extends StatelessWidget {
  const _ProcedureHero({required this.procedure});

  final ProcedureModel procedure;

  @override
  Widget build(BuildContext context) {
    final percent = (procedure.progress * 100).round();

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
                  label: '${procedure.summary.officesToVisit} offices',
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
                        'Step ${procedure.currentStep} of ${procedure.totalSteps} - $percent% done',
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
                          ).colorScheme.primary.withValues(alpha: 0.12),
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
                    ).colorScheme.primary.withValues(alpha: 0.12),
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
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
