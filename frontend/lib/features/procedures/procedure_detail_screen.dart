import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/constants/route_paths.dart';
import '../../core/genui/genui_providers.dart';
import '../../core/genui/procedure_page_composer.dart';
import '../../core/genui/profile_config.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/utils/async_value_widget.dart';
import '../../renderer/block_renderer.dart';
import '../../shared/models/procedure_model.dart';

class ProcedureDetailScreen extends ConsumerStatefulWidget {
  const ProcedureDetailScreen({required this.slug, this.historyId, super.key});

  final String slug;
  final String? historyId;

  @override
  ConsumerState<ProcedureDetailScreen> createState() =>
      _ProcedureDetailScreenState();
}

class _ProcedureDetailScreenState extends ConsumerState<ProcedureDetailScreen> {
  bool _simplified = false;

  @override
  Widget build(BuildContext context) {
    final detailValue = widget.historyId != null && widget.historyId!.isNotEmpty
        ? ref.watch(historyDetailProvider(widget.historyId!))
        : ref.watch(procedureDetailProvider(widget.slug));
    final profile = ref.watch(effectiveProfileProvider);
    final profileTheme = getThemeByProfile(profile);
    final locale = ref.watch(localeProvider);
    final isArabic = locale == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: profileTheme.pageBackground,
        appBar: AppBar(
          title: Text(
            isArabic ? 'إجراء' : locale == 'en' ? 'Procedure' : 'Procédure',
          ),
        ),
        body: SafeArea(
          child: AsyncValueWidget<ProcedureModel>(
            value: detailValue,
            data: (procedure) {
              final composedBlocks = ProcedurePageComposer.compose(
                procedure: procedure,
                profile: profile,
                locale: locale,
                simplified: _simplified,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _ProcedureHero(
                    procedure: procedure,
                    locale: locale,
                    simplified: _simplified,
                    onToggleSimplified: () {
                      setState(() {
                        _simplified = !_simplified;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  BlockRenderer(blocks: composedBlocks),
                  const SizedBox(height: 6),
                  FilledButton.icon(
                    onPressed: () => context.push(
                      '${RoutePaths.offices}?stepId=mutation-dossier',
                    ),
                    icon: const Icon(Icons.near_me_rounded),
                    label: Text(
                      isArabic
                          ? 'اعثر على أقرب مكتب'
                          : locale == 'en'
                              ? 'Find nearest office'
                              : 'Trouver le bureau le plus proche',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProcedureHero extends StatelessWidget {
  const _ProcedureHero({
    required this.procedure,
    required this.locale,
    required this.simplified,
    required this.onToggleSimplified,
  });

  final ProcedureModel procedure;
  final String locale;
  final bool simplified;
  final VoidCallback onToggleSimplified;

  @override
  Widget build(BuildContext context) {
    final isArabic = locale == 'ar';
    final stepsCount = procedure.totalSteps;
    final offices = procedure.summary.officesToVisit;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              procedure.summary.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF101828),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'اتبع الخطوات التالية لإتمام الإجراء بسرعة.'
                  : locale == 'en'
                      ? 'Follow these clear steps to complete your procedure.'
                      : 'Suivez ces étapes claires pour terminer votre démarche.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF667085),
                  ),
            ),
            const SizedBox(height: 14),
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
                  icon: Icons.format_list_numbered_rounded,
                  label: isArabic
                      ? '$stepsCount خطوات'
                      : locale == 'en'
                          ? '$stepsCount steps'
                          : '$stepsCount étapes',
                ),
                if (offices > 0)
                  _SummaryPill(
                    icon: Icons.account_balance_rounded,
                    label: isArabic
                        ? '$offices مكاتب'
                        : locale == 'en'
                            ? '$offices offices'
                            : '$offices bureaux',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onToggleSimplified,
                icon: Icon(
                  simplified ? Icons.visibility_rounded : Icons.visibility_outlined,
                ),
                label: Text(
                  isArabic
                      ? (simplified ? 'عرض النسخة الكاملة' : 'عرض نسخة مبسطة')
                      : locale == 'en'
                          ? (simplified
                              ? 'Show full version'
                              : 'Show simplified version')
                          : (simplified
                              ? 'Voir version complète'
                              : 'Voir version simplifiée'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFD0D5DD),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF344054),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF344054),
                ),
          ),
        ],
      ),
    );
  }
}
