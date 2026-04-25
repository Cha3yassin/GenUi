import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/models/procedure_step_model.dart';

/// Flat numbered step list — purely informational like a recipe.
/// No timeline connector, no active/done states — all steps look identical.
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              _FlatStepRow(
                step: steps[index],
                index: index,
              ),
              if (index < steps.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(
                    color: AppTheme.borderLight.withOpacity(0.6),
                    height: 1,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single flat step row: number badge + bold title + description + institution.
class _FlatStepRow extends StatelessWidget {
  const _FlatStepRow({
    required this.step,
    required this.index,
  });

  final ProcedureStepModel step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtle number badge — uniform for all steps
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.terracotta.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.terracotta,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bold title
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                // Short description
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                // Institution name at bottom
                if (step.officeType.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        size: 14,
                        color: AppTheme.olive,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          step.officeType,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.olive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
