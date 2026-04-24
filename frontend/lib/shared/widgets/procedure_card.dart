import 'package:flutter/material.dart';

import '../../core/api/language_utils.dart';
import '../../core/genui/category_config.dart';
import '../../core/genui/procedure_config.dart';
import '../../core/genui/profile_config.dart';
import '../../core/theme/app_theme.dart';
import '../models/procedure_summary_model.dart';
import 'status_badge.dart';

class ProcedureCard extends StatelessWidget {
  const ProcedureCard({
    required this.procedure,
    required this.onTap,
    this.profileType,
    this.highlightLabel,
    super.key,
  });

  final ProcedureSummaryModel procedure;
  final VoidCallback onTap;
  final ProfileType? profileType;
  final String? highlightLabel;

  @override
  Widget build(BuildContext context) {
    final isArabic = LanguageUtils.isArabic(procedure.title);
    final accent = procedureCategoryAccent(procedure.categoryId);
    final profileDescription = profileType == null
        ? procedure.summary
        : (getProcedureConfig(procedure.slug)?.description(profileType!) ?? '');
    final variant =
        profileType == null ? null : getProfileUiVariant(profileType!);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: variant?.categoryCardVariant == CategoryCardVariant.structured
          ? _BusinessProcedureCard(
              procedure: procedure,
              accent: accent,
              profileDescription: profileDescription,
              highlightLabel: highlightLabel,
              onTap: onTap,
            )
          : _PersonalProcedureCard(
              procedure: procedure,
              accent: accent,
              profileDescription: profileDescription,
              highlightLabel: highlightLabel,
              onTap: onTap,
            ),
    );
  }
}

class _PersonalProcedureCard extends StatelessWidget {
  const _PersonalProcedureCard({
    required this.procedure,
    required this.accent,
    required this.profileDescription,
    required this.highlightLabel,
    required this.onTap,
  });

  final ProcedureSummaryModel procedure;
  final Color accent;
  final String profileDescription;
  final String? highlightLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(label: procedure.categoryLabel, color: accent),
                  if (highlightLabel != null)
                    StatusBadge(
                      label: highlightLabel!,
                      color: accent,
                      icon: Icons.auto_awesome_rounded,
                      backgroundAlpha: 0.08,
                      borderAlpha: 0.14,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                procedure.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                profileDescription.isNotEmpty
                    ? profileDescription
                    : procedure.summary,
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

class _BusinessProcedureCard extends StatelessWidget {
  const _BusinessProcedureCard({
    required this.procedure,
    required this.accent,
    required this.profileDescription,
    required this.highlightLabel,
    required this.onTap,
  });

  final ProcedureSummaryModel procedure;
  final Color accent;
  final String profileDescription;
  final String? highlightLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work_outline_rounded, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            StatusBadge(
                              label: getCategoryEnterpriseLabel(
                                procedure.categoryId,
                              ),
                              color: accent,
                              backgroundAlpha: 0.07,
                              borderAlpha: 0.12,
                            ),
                            if (highlightLabel != null)
                              StatusBadge(
                                label: highlightLabel!,
                                color: accent,
                                icon: Icons.insights_rounded,
                                backgroundAlpha: 0.08,
                                borderAlpha: 0.14,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          procedure.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: accent.withValues(alpha: 0.12)),
              const SizedBox(height: 10),
              Text(
                profileDescription.isNotEmpty
                    ? profileDescription
                    : procedure.summary,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusTile(
                      label: 'Delai',
                      value: procedure.estimatedDuration,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusTile(
                      label: 'Cout',
                      value: procedure.estimatedCost,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusTile(
                      label: 'Bureaux',
                      value: '${procedure.officesToVisit}',
                      accent: accent,
                    ),
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

Color procedureCategoryAccent(String categoryId) {
  return switch (categoryId) {
    'civil_status' => const Color(0xFF2F6FED),
    'vehicles' => const Color(0xFF2563EB),
    'taxation' => const Color(0xFF1E40AF),
    'residence' => const Color(0xFF3B82F6),
    'passports_travel' => const Color(0xFF0EA5E9),
    'business' => const Color(0xFF1D4ED8),
    'social_security' => const Color(0xFF0F4C81),
    'property' => const Color(0xFF4F7CAC),
    _ => const Color(0xFF2563EB),
  };
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

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                ),
          ),
        ],
      ),
    );
  }
}
