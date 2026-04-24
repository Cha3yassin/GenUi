import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/category_procedures_data.dart';
import '../../core/constants/route_paths.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';

/// Shows the real list of Tunisian procedures for a given category.
/// Each item taps through to GenUI which generates the full procedure detail.
class CategoryProceduresScreen extends ConsumerWidget {
  const CategoryProceduresScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final procedures = CategoryProceduresData.forCategory(categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(_titleForCategory(categoryId, locale))),
      body: SafeArea(
        child: procedures.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    locale == 'ar'
                        ? 'لا توجد إجراءات متاحة لهذه الفئة بعد.'
                        : locale == 'en'
                            ? 'No procedures available in this category yet.'
                            : 'Aucune procédure disponible dans cette catégorie.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemCount: procedures.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final proc = procedures[index];
                  final name = CategoryProceduresData.localizedName(
                    proc,
                    locale,
                  );
                  final slug = proc['slug'] as String;
                  final icon = CategoryProceduresData.iconFor(
                    proc['icon'] as String,
                  );

                  return _ProcedureTile(
                    title: name,
                    slug: slug,
                    icon: icon,
                    categoryId: categoryId,
                    onTap: () => context.push(RoutePaths.procedure(slug)),
                  );
                },
              ),
      ),
    );
  }

  String _titleForCategory(String id, String locale) {
    return switch (id) {
      'civil_status' => locale == 'ar'
          ? 'الحالة المدنية'
          : locale == 'en'
              ? 'Civil Status'
              : 'État Civil',
      'vehicles' => locale == 'ar'
          ? 'المركبات'
          : locale == 'en'
              ? 'Vehicles'
              : 'Véhicules',
      'taxation' => locale == 'ar'
          ? 'الضرائب'
          : locale == 'en'
              ? 'Taxation'
              : 'Fiscalité',
      'residence' => locale == 'ar'
          ? 'الإقامة'
          : locale == 'en'
              ? 'Residence'
              : 'Résidence',
      'passports_travel' => locale == 'ar'
          ? 'جوازات السفر'
          : locale == 'en'
              ? 'Passports & Travel'
              : 'Passeports & Voyages',
      'business' => locale == 'ar'
          ? 'الأعمال التجارية'
          : locale == 'en'
              ? 'Business'
              : 'Création d\'entreprise',
      'social_security' => locale == 'ar'
          ? 'الضمان الاجتماعي'
          : locale == 'en'
              ? 'Social Security'
              : 'Sécurité Sociale',
      'property' => locale == 'ar'
          ? 'العقارات'
          : locale == 'en'
              ? 'Property'
              : 'Immobilier',
      _ => locale == 'ar'
          ? 'الإجراءات'
          : locale == 'en'
              ? 'Procedures'
              : 'Procédures',
    };
  }
}

// ── Premium procedure tile ────────────────────────────────────────────────────

class _ProcedureTile extends StatefulWidget {
  const _ProcedureTile({
    required this.title,
    required this.slug,
    required this.icon,
    required this.categoryId,
    required this.onTap,
  });

  final String title;
  final String slug;
  final IconData icon;
  final String categoryId;
  final VoidCallback onTap;

  @override
  State<_ProcedureTile> createState() => _ProcedureTileState();
}

class _ProcedureTileState extends State<_ProcedureTile> {
  bool _isHovered = false;

  Color get _accentColor {
    return switch (widget.categoryId) {
      'civil_status' => const Color(0xFF68775A),
      'vehicles' => const Color(0xFFB45745),
      'taxation' => const Color(0xFF843B31),
      'residence' => const Color(0xFF5A6E77),
      'passports_travel' => const Color(0xFF6B5A77),
      'business' => const Color(0xFF6F625D),
      'social_security' => const Color(0xFF4A7768),
      'property' => const Color(0xFF7A6545),
      _ => const Color(0xFF5D6F62),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _isHovered
              ? _accentColor.withOpacity(0.04)
              : AppTheme.paper,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? _accentColor.withOpacity(0.25)
                : AppTheme.borderLight,
            width: _isHovered ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      color: _accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _subtitleForSlug(widget.slug),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppTheme.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: _accentColor.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleForSlug(String slug) {
    // Generate a helpful subtitle from the slug
    return 'Tap to generate step-by-step guide';
  }
}
