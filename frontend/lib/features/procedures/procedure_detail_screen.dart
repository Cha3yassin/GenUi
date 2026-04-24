import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/language_utils.dart';
import '../../core/constants/route_paths.dart';
import '../../core/genui/genui_providers.dart';
import '../../core/genui/procedure_page_composer.dart';
import '../../core/genui/procedure_semantic_theme.dart';
import '../../core/genui/profile_config.dart';
import '../../core/locale/locale_provider.dart';
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
    final detailValue = historyId != null && historyId!.isNotEmpty
        ? ref.watch(historyDetailProvider(historyId!))
        : ref.watch(procedureDetailProvider(slug));
    final profile = ref.watch(effectiveProfileProvider);
    final profileTheme = getThemeByProfile(profile);
    final locale = ref.watch(localeProvider);
    final isArabic = LanguageUtils.isArabic(slug);
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: profileTheme.pageBackground,
        appBar: AppBar(title: Text(isArabic ? 'إجراء' : 'Procedure')),
        body: SafeArea(
          child: AsyncValueWidget<ProcedureModel>(
            value: detailValue,
            data: (procedure) {
              final semanticTheme = inferProcedureSemanticTheme(
                procedure,
                locale: locale,
              );
              final composedBlocks = ProcedurePageComposer.compose(
                procedure: procedure,
                profile: profile,
                locale: locale,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _ProcedureHero(
                    procedure: procedure,
                    isArabic: isArabic,
                    profile: profile,
                    theme: profileTheme,
                    semanticTheme: semanticTheme,
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
                      isArabic ? 'اعثر على أقرب مكتب' : 'Find nearest office',
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
    required this.isArabic,
    required this.profile,
    required this.theme,
    required this.semanticTheme,
  });

  final ProcedureModel procedure;
  final bool isArabic;
  final ProfileType profile;
  final ProfileThemeData theme;
  final ProcedureSemanticTheme semanticTheme;

  @override
  Widget build(BuildContext context) {
    final isEnterprise = profile == ProfileType.enterprise;
    final heroGradient = isEnterprise
        ? <Color>[
            const Color(0xFF172033),
            semanticTheme.secondary,
            theme.secondaryAccent,
          ]
        : <Color>[
            Colors.white,
            semanticTheme.surface,
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: heroGradient,
        ),
        borderRadius: BorderRadius.circular(isEnterprise ? 24 : 22),
        border: Border.all(
          color: isEnterprise
              ? semanticTheme.accent.withValues(alpha: 0.24)
              : theme.borderTint,
        ),
        boxShadow: [
          BoxShadow(
            color: semanticTheme.accent.withValues(
              alpha: isEnterprise ? 0.24 : 0.08,
            ),
            blurRadius: isEnterprise ? 28 : 18,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isEnterprise) ...[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: semanticTheme.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      semanticTheme.icon,
                      color: semanticTheme.accent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBadge(
                        label: semanticTheme.label,
                        color: isEnterprise
                            ? theme.professionalAccent
                            : semanticTheme.accent,
                        backgroundAlpha: isEnterprise ? 0.14 : 0.08,
                        borderAlpha: isEnterprise ? 0.20 : 0.14,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        procedure.summary.title,
                        style: (isEnterprise
                                ? Theme.of(context).textTheme.headlineMedium
                                : GoogleFonts.playfairDisplayTextTheme(
                                    Theme.of(context).textTheme,
                                  ).headlineMedium)
                            ?.copyWith(
                          color: isEnterprise ? theme.heroForeground : null,
                          fontSize: isEnterprise ? 30 : 26,
                          height: 1.10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _heroSubtitle(isEnterprise, semanticTheme),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isEnterprise
                                  ? theme.heroMutedForeground
                                  : const Color(0xFF60759A),
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isEnterprise) ...[
                  const SizedBox(width: 16),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isEnterprise
                          ? theme.professionalAccent
                          : semanticTheme.accent,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.professionalAccent.withValues(alpha: 0.30),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      semanticTheme.icon,
                      color: theme.accent,
                      size: 30,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryPill(
                  icon: Icons.schedule_rounded,
                  label: procedure.summary.estimatedDuration,
                  profile: profile,
                  theme: theme,
                ),
                _SummaryPill(
                  icon: Icons.payments_rounded,
                  label: procedure.summary.estimatedCost,
                  profile: profile,
                  theme: theme,
                ),
                _SummaryPill(
                  icon: Icons.account_balance_rounded,
                  label: isArabic
                      ? '${procedure.summary.officesToVisit} مكاتب'
                      : '${procedure.summary.officesToVisit} offices',
                  profile: profile,
                  theme: theme,
                ),
              ],
            ),
            if (isEnterprise) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _EnterpriseSignalTile(
                      label: 'Mode GenUI',
                      value: semanticTheme.label,
                      icon: Icons.verified_user_rounded,
                      color: semanticTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _EnterpriseSignalTile(
                      label: 'Composition',
                      value: semanticTheme.summaryHint,
                      icon: Icons.domain_verification_rounded,
                      color: theme.professionalAccent,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _heroSubtitle(
  bool isEnterprise,
  ProcedureSemanticTheme semanticTheme,
) {
  if (isEnterprise) {
    return switch (semanticTheme.id) {
      'business_launch' =>
        'Vue executive du lancement, de la conformite et des activations administratives.',
      'legal_transfer' =>
        'Pilotage du dossier contractuel, des pieces de cession et du passage administratif.',
      'acquisition' =>
        'Lecture orientee budget, fournisseur et mise en circulation de l acquisition.',
      'renewal' =>
        'Vue operationnelle du renouvellement, des depots et du retrait final.',
      _ =>
        'Vue executive de la formalite, des couts et des interactions administratives.',
    };
  }

  return switch (semanticTheme.id) {
    'legal_transfer' =>
      'Resume clair du transfert, des pieces contractuelles et du bureau a contacter.',
    'acquisition' =>
      'Resume clair de l achat, des frais et des documents a preparer.',
    'renewal' =>
      'Resume clair de la mise a jour, des depots et du retrait final.',
    'business_launch' =>
      'Vue simplifiee de la creation, des couts et des etapes de lancement.',
    _ => 'Resume clair de la demarche, du cout et du passage au guichet.',
  };
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.profile,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ProfileType profile;
  final ProfileThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isEnterprise = profile == ProfileType.enterprise;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isEnterprise
            ? Colors.white.withValues(alpha: 0.10)
            : theme.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(isEnterprise ? 14 : 999),
        border: Border.all(
          color: isEnterprise
              ? Colors.white.withValues(alpha: 0.12)
              : theme.accent.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isEnterprise ? theme.professionalAccent : theme.accent,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isEnterprise ? Colors.white : theme.accent,
                ),
          ),
        ],
      ),
    );
  }
}

class _EnterpriseSignalTile extends StatelessWidget {
  const _EnterpriseSignalTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
