import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/category_procedures_data.dart';
import '../../core/genui/category_config.dart';
import '../../core/genui/procedure_config.dart';
import '../../core/genui/profile_config.dart';
import '../../core/theme/app_theme.dart';
import '../models/category_model.dart';
import 'status_badge.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    required this.onTap,
    required this.onProcedureTap,
    required this.profileType,
    this.locale = 'fr',
    this.isFeatured = false,
    super.key,
  });

  final CategoryModel category;
  final VoidCallback onTap;
  final void Function(String slug) onProcedureTap;
  final ProfileType profileType;
  final String locale;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final categoryStyle = getCategoryStyle(category.id);
    final uiVariant = getProfileUiVariant(profileType);
    final procedures = prioritizeProcedureEntries(
      CategoryProceduresData.forCategory(category.id),
      profileType,
    );
    final visibleProcedures = procedures.take(3).toList();

    return uiVariant.categoryCardVariant == CategoryCardVariant.structured
        ? _StructuredCategoryCard(
            category: category,
            locale: locale,
            procedures: visibleProcedures,
            categoryStyle: categoryStyle,
            isFeatured: isFeatured,
            onTap: onTap,
            onProcedureTap: onProcedureTap,
          )
        : _SoftCategoryCard(
            category: category,
            locale: locale,
            procedures: visibleProcedures,
            categoryStyle: categoryStyle,
            isFeatured: isFeatured,
            onTap: onTap,
            onProcedureTap: onProcedureTap,
          );
  }
}

class _SoftCategoryCard extends StatelessWidget {
  const _SoftCategoryCard({
    required this.category,
    required this.locale,
    required this.procedures,
    required this.categoryStyle,
    required this.isFeatured,
    required this.onTap,
    required this.onProcedureTap,
  });

  final CategoryModel category;
  final String locale;
  final List<Map<String, dynamic>> procedures;
  final CategoryUiConfig categoryStyle;
  final bool isFeatured;
  final VoidCallback onTap;
  final void Function(String slug) onProcedureTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxChipWidth = constraints.maxWidth - 36;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Ink(
              decoration: BoxDecoration(
                color: categoryStyle.backgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isFeatured
                      ? category.accentColor.withValues(alpha: 0.26)
                      : AppTheme.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: category.accentColor.withValues(alpha: 0.06),
                    blurRadius: isFeatured ? 24 : 16,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: category.accentColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isFeatured)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: StatusBadge(
                                    label: 'Priorite',
                                    color: category.accentColor,
                                    backgroundAlpha: 0.08,
                                    borderAlpha: 0.14,
                                  ),
                                ),
                              Text(
                                category.title(locale),
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Demarches personnelles et besoins du quotidien.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (procedures.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: procedures.map((proc) {
                          final name = CategoryProceduresData.localizedName(
                            proc,
                            locale,
                          );

                          return _SoftProcedureChip(
                            label: name,
                            color: category.accentColor,
                            maxWidth: maxChipWidth,
                            onTap: () => onProcedureTap(proc['slug'] as String),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StructuredCategoryCard extends StatelessWidget {
  const _StructuredCategoryCard({
    required this.category,
    required this.locale,
    required this.procedures,
    required this.categoryStyle,
    required this.isFeatured,
    required this.onTap,
    required this.onProcedureTap,
  });

  final CategoryModel category;
  final String locale;
  final List<Map<String, dynamic>> procedures;
  final CategoryUiConfig categoryStyle;
  final bool isFeatured;
  final VoidCallback onTap;
  final void Function(String slug) onProcedureTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFeatured
                  ? category.accentColor.withValues(alpha: 0.28)
                  : const Color(0xFFD7DEE8),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172033).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: isFeatured
                          ? const Color(0xFFD6A94A)
                          : category.accentColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: category.accentColor
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category.icon,
                                color: category.accentColor,
                                size: 20,
                              ),
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
                                          category.id,
                                        ),
                                        color: category.accentColor,
                                        backgroundAlpha: 0.06,
                                        borderAlpha: 0.12,
                                      ),
                                      if (isFeatured)
                                        const StatusBadge(
                                          label: 'STATUT PRIORITAIRE',
                                          color: Color(0xFFD6A94A),
                                          backgroundAlpha: 0.10,
                                          borderAlpha: 0.18,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    category.title(locale),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF101828),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bloc de gestion et de conformite.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFF667085),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(
                          height: 1,
                          color: category.accentColor.withValues(alpha: 0.12),
                        ),
                        const SizedBox(height: 10),
                        for (final proc in procedures)
                          _StructuredProcedureRow(
                            label: CategoryProceduresData.localizedName(
                              proc,
                              locale,
                            ),
                            color: category.accentColor,
                            onTap: () => onProcedureTap(proc['slug'] as String),
                          ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Consulter',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: category.accentColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftProcedureChip extends StatelessWidget {
  const _SoftProcedureChip({
    required this.label,
    required this.color,
    required this.maxWidth,
    required this.onTap,
  });

  final String label;
  final Color color;
  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.86),
            ),
          ),
        ),
      ),
    );
  }
}

class _StructuredProcedureRow extends StatelessWidget {
  const _StructuredProcedureRow({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: color.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
