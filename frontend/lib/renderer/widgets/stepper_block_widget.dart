import 'package:flutter/material.dart';

import '../../shared/models/procedure_step_model.dart';

class StepperBlockWidget extends StatelessWidget {
  const StepperBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final steps = (data['steps'] as List<dynamic>? ?? [])
        .map(
          (item) => ProcedureStepModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    final currentLabel = data['currentLabel'] as String? ?? 'Current';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            for (var index = 0; index < steps.length; index++)
              _StepRow(
                step: steps[index],
                index: index,
                isLast: index == steps.length - 1,
                currentLabel: currentLabel,
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
    required this.currentLabel,
  });

  final ProcedureStepModel step;
  final int index;
  final bool isLast;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = step.isCompleted || step.isCurrent
        ? colorScheme.primary
        : colorScheme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: step.isCompleted
                      ? colorScheme.primary
                      : activeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: activeColor, width: 1.5),
                ),
                child: Center(
                  child: step.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        )
                      : Text(
                          '${index + 1}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: activeColor),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: activeColor.withOpacity(0.24),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (step.isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            currentLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (step.officeType.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            step.officeType,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
