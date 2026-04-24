import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/category_procedures_data.dart';
import '../../core/constants/route_paths.dart';
import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';
import '../../core/genui/procedure_config.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/animated_reveal.dart';
import '../../shared/widgets/status_badge.dart';

class CategoryProceduresScreen extends ConsumerWidget {
  const CategoryProceduresScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final profile = ref.watch(effectiveProfileProvider);
    final theme = getThemeByProfile(profile);
    final uiVariant = getProfileUiVariant(profile);
    final procedures = prioritizeProcedureEntries(
      CategoryProceduresData.forCategory(categoryId),
      profile,
    );

    return Scaffold(
      backgroundColor: theme.pageBackground,
      appBar: AppBar(title: Text(_titleForCategory(categoryId, locale))),
      body: SafeArea(
        child: procedures.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    locale == 'en'
                        ? 'No procedures available in this category yet.'
                        : 'Aucune procedure disponible dans cette categorie.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  20,
                  uiVariant.categoryCardVariant ==
                          CategoryCardVariant.structured
                      ? 20
                      : 12,
                  20,
                  32,
                ),
                itemCount: procedures.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final proc = procedures[index];
                  final name =
                      CategoryProceduresData.localizedName(proc, locale);
                  final slug = proc['slug'] as String;
                  final icon =
                      CategoryProceduresData.iconFor(proc['icon'] as String);

                  return AnimatedReveal(
                    delay: Duration(milliseconds: 45 * index),
                    child: _ProcedureTile(
                      title: name,
                      slug: slug,
                      icon: icon,
                      categoryId: categoryId,
                      profile: profile,
                      theme: theme,
                      isFeatured: index < 2,
                      onTap: () => context.push(RoutePaths.procedure(slug)),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _titleForCategory(String id, String locale) {
    return switch (id) {
      'civil_status' => locale == 'en' ? 'Civil Status' : 'Etat Civil',
      'vehicles' => locale == 'en' ? 'Vehicles' : 'Vehicules',
      'taxation' => locale == 'en' ? 'Taxation' : 'Fiscalite',
      'residence' => locale == 'en' ? 'Residence' : 'Residence',
      'passports_travel' =>
        locale == 'en' ? 'Passports & Travel' : 'Passeports & Voyages',
      'business' => locale == 'en' ? 'Business' : 'Creation d entreprise',
      'social_security' =>
        locale == 'en' ? 'Social Security' : 'Securite Sociale',
      'property' => locale == 'en' ? 'Property' : 'Immobilier',
      _ => locale == 'en' ? 'Procedures' : 'Procedures',
    };
  }
}

class _ProcedureTile extends StatefulWidget {
  const _ProcedureTile({
    required this.title,
    required this.slug,
    required this.icon,
    required this.categoryId,
    required this.profile,
    required this.theme,
    required this.isFeatured,
    required this.onTap,
  });

  final String title;
  final String slug;
  final IconData icon;
  final String categoryId;
  final ProfileType profile;
  final ProfileThemeData theme;
  final bool isFeatured;
  final VoidCallback onTap;

  @override
  State<_ProcedureTile> createState() => _ProcedureTileState();
}

class _ProcedureTileState extends State<_ProcedureTile> {
  bool _isHovered = false;

  Color get _accentColor {
    return switch (widget.categoryId) {
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

  @override
  Widget build(BuildContext context) {
    final procedureConfig = getProcedureConfig(widget.slug);
    final isEnterprise = widget.profile == ProfileType.enterprise;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isEnterprise
              ? (_isHovered
                  ? Colors.white
                  : widget.theme.surfaceTint.withValues(alpha: 0.4))
              : (_isHovered
                  ? _accentColor.withValues(alpha: 0.04)
                  : AppTheme.paper),
          borderRadius: BorderRadius.circular(isEnterprise ? 16 : 18),
          border: Border.all(
            color: isEnterprise
                ? (_isHovered || widget.isFeatured
                    ? widget.theme.professionalAccent.withValues(alpha: 0.34)
                    : widget.theme.borderTint)
                : (_isHovered || widget.isFeatured
                    ? _accentColor.withValues(alpha: 0.25)
                    : AppTheme.borderLight),
            width: _isHovered || widget.isFeatured ? 1.5 : 1,
          ),
          boxShadow: isEnterprise
              ? [
                  BoxShadow(
                    color: widget.theme.accent.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(isEnterprise ? 16 : 18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: isEnterprise
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5,
                          height: 74,
                          decoration: BoxDecoration(
                            color: widget.isFeatured
                                ? widget.theme.professionalAccent
                                : widget.theme.secondaryAccent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: widget.theme.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.theme.secondaryAccent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  StatusBadge(
                                    label:
                                        _businessBadgeLabel(widget.categoryId),
                                    color: widget.theme.secondaryAccent,
                                    backgroundAlpha: 0.06,
                                    borderAlpha: 0.12,
                                  ),
                                  if (widget.isFeatured)
                                    StatusBadge(
                                      label: 'PRIORITAIRE',
                                      color: widget.theme.professionalAccent,
                                      backgroundAlpha: 0.10,
                                      borderAlpha: 0.18,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.title,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF101828),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                procedureConfig?.description(widget.profile) ??
                                    'Tap to open this procedure guide.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 18,
                          color: widget.theme.professionalAccent,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child:
                              Icon(widget.icon, color: _accentColor, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  if (widget.isFeatured)
                                    StatusBadge(
                                      label: 'Useful',
                                      color: _accentColor,
                                      backgroundAlpha: 0.08,
                                      borderAlpha: 0.14,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                procedureConfig?.description(widget.profile) ??
                                    'Tap to open this procedure guide.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppTheme.mutedInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: _accentColor.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _businessBadgeLabel(String categoryId) {
    return switch (categoryId) {
      'taxation' => 'Fiscal',
      'business' => 'Registre',
      'social_security' => 'Social',
      'property' => 'Juridique',
      _ => 'Administratif',
    };
  }
}
