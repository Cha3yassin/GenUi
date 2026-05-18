import 'package:flutter/material.dart';

import '../../core/api/language_utils.dart';
import '../../core/locale/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../models/procedure_summary_model.dart';
import 'status_badge.dart';

class ProcedureCard extends StatelessWidget {
  const ProcedureCard({
    required this.procedure,
    required this.onTap,
    this.locale = 'fr',
    super.key,
  });

  final ProcedureSummaryModel procedure;
  final VoidCallback onTap;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isArabic = locale == 'ar' || LanguageUtils.isArabic(procedure.title);
    final cost = procedure.estimatedCost.trim();
    final isFree = cost == '0 TND' || cost == '0.0 TND' || cost == '0,0 TND' || cost == '0';

    Widget card = Card(
      child: InkWell(
        onTap: procedure.isAdministrative ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
                      label: isFree ? 'Sans frais' : procedure.estimatedCost,
                      isSuccess: isFree,
                    ),
                    _MetaPill(
                      icon: Icons.account_balance_rounded,
                      label:
                          '${procedure.officesToVisit} ${AppStrings.get('offices_label', locale)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!procedure.isAdministrative) {
      return Opacity(
        opacity: 0.5,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: IgnorePointer(child: card),
        ),
      );
    }
    return card;
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label, this.isSuccess = false});

  final IconData icon;
  final String label;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppTheme.olive : Theme.of(context).colorScheme.secondary;
    final borderColor = isSuccess ? AppTheme.olive.withOpacity(0.3) : Theme.of(context).colorScheme.outline;
    final bgColor = isSuccess ? AppTheme.olive.withOpacity(0.08) : Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}
