import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';
import '../../shared/models/procedure_step_model.dart';
import '../../shared/widgets/status_badge.dart';

class StepperBlockWidget extends ConsumerWidget {
  const StepperBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = (data['steps'] as List<dynamic>? ?? [])
        .map(
          (item) => ProcedureStepModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    final profile = ref.watch(effectiveProfileProvider);
    final theme = getThemeByProfile(profile);
    final isEnterprise = profile == ProfileType.enterprise;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isEnterprise ? 18 : 22),
        border: Border.all(color: theme.borderTint),
        boxShadow: [
          BoxShadow(
            color: theme.accent.withValues(alpha: isEnterprise ? 0.06 : 0.04),
            blurRadius: isEnterprise ? 18 : 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            for (var index = 0; index < steps.length; index++)
              _StepRow(
                step: steps[index],
                index: index,
                isLast: index == steps.length - 1,
                profile: profile,
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.index,
    required this.isLast,
    required this.profile,
    required this.theme,
  });

  final ProcedureStepModel step;
  final int index;
  final bool isLast;
  final ProfileType profile;
  final ProfileThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isEnterprise = profile == ProfileType.enterprise;
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = isEnterprise
        ? theme.secondaryAccent
        : (step.isCompleted || step.isCurrent
            ? colorScheme.primary
            : colorScheme.outline);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isEnterprise ? 38 : 34,
                height: isEnterprise ? 38 : 34,
                decoration: BoxDecoration(
                  color: isEnterprise
                      ? (step.isCompleted || step.isCurrent
                          ? theme.professionalAccent.withValues(alpha: 0.16)
                          : theme.surfaceTint)
                      : (step.isCompleted
                          ? colorScheme.primary
                          : activeColor.withValues(alpha: 0.12)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isEnterprise
                        ? (step.isCompleted || step.isCurrent
                            ? theme.professionalAccent
                            : activeColor)
                        : activeColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: step.isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: isEnterprise
                              ? theme.professionalAccent
                              : Colors.white,
                        )
                      : Text(
                          '${index + 1}',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: isEnterprise
                                        ? theme.secondaryAccent
                                        : activeColor,
                                  ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: isEnterprise ? 3 : 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isEnterprise
                          ? theme.professionalAccent.withValues(alpha: 0.22)
                          : activeColor.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Container(
                padding: EdgeInsets.all(isEnterprise ? 16 : 0),
                decoration: isEnterprise
                    ? BoxDecoration(
                        color: theme.surfaceTint.withValues(alpha: 0.60),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.borderTint),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEnterprise)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: StatusBadge(
                          label: index == 0 ? 'Etape prioritaire' : 'Etape',
                          color: index == 0
                              ? theme.professionalAccent
                              : theme.secondaryAccent,
                          backgroundAlpha: 0.08,
                          borderAlpha: 0.14,
                        ),
                      ),
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color:
                                isEnterprise ? const Color(0xFF101828) : null,
                            fontWeight: isEnterprise ? FontWeight.w700 : null,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                isEnterprise ? const Color(0xFF667085) : null,
                            height: 1.55,
                          ),
                    ),
                    if (step.officeType.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            size: 16,
                            color: isEnterprise
                                ? theme.secondaryAccent
                                : colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              step.officeType,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: isEnterprise
                                        ? theme.secondaryAccent
                                        : null,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
