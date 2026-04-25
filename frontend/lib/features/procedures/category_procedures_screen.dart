import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/category_procedures_data.dart';
import '../../core/constants/route_paths.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';

/// Shows the list of Tunisian procedures for a given category.
/// Each item taps through to the full procedure detail view.
class CategoryProceduresScreen extends ConsumerWidget {
  const CategoryProceduresScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final procedures = CategoryProceduresData.forCategory(categoryId);
    final categoryTitle = AppStrings.get('cat_$categoryId', locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: procedures.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppStrings.get('no_procedures_in_category', locale),
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
                    icon: icon,
                    categoryId: categoryId,
                    onTap: () => context.push(RoutePaths.procedure(slug)),
                  );
                },
              ),
      ),
    );
  }
}

// ── Clean procedure tile: icon + title + chevron ──────────────────────────────

class _ProcedureTile extends StatefulWidget {
  const _ProcedureTile({
    required this.title,
    required this.icon,
    required this.categoryId,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String categoryId;
  final VoidCallback onTap;

  @override
  State<_ProcedureTile> createState() => _ProcedureTileState();
}

class _ProcedureTileState extends State<_ProcedureTile> {
  bool _isHovered = false;

  Color get _accentColor {
    return AppTheme.categoryColors[widget.categoryId] ??
        const Color(0xFF5D6F62);
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
          borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              child: Row(
                children: [
                  // Larger icon with warm tinted circular background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.icon,
                      color: _accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title only — no subtitle
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),

                  // Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
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
}
