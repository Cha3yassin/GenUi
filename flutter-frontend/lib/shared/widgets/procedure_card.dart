import 'package:flutter/material.dart';

import '../models/procedure_summary_model.dart';
import 'status_badge.dart';

class ProcedureCard extends StatelessWidget {
  const ProcedureCard({
    required this.procedure,
    required this.onTap,
    super.key,
  });

  final ProcedureSummaryModel procedure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(label: procedure.categoryLabel),
              const SizedBox(height: 12),
              Text(
                procedure.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                procedure.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(
                    icon: Icons.schedule_rounded,
                    label: procedure.estimatedDuration,
                  ),
                  _MetaPill(
                    icon: Icons.payments_rounded,
                    label: procedure.estimatedCost,
                  ),
                  _MetaPill(
                    icon: Icons.account_balance_rounded,
                    label: '${procedure.officesToVisit} offices',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
