import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/category_procedures_data.dart';
import '../../core/theme/app_theme.dart';
import '../models/category_model.dart';

/// Compact category card with embedded procedure mini-chips.
/// Tapping the card → navigates to category procedures list.
/// Tapping a chip → navigates directly to that procedure (GenUI).
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    required this.onTap,
    required this.onProcedureTap,
    this.locale = 'fr',
    super.key,
  });

  final CategoryModel category;
  final VoidCallback onTap;

  /// Called when a procedure chip is tapped. Passes the procedure slug.
  final void Function(String slug) onProcedureTap;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final procedures = CategoryProceduresData.forCategory(category.id);
    // Show max 3 procedure chips
    final visibleProcedures = procedures.take(3).toList();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon + Title row ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: category.accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.accentColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.title(locale),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (visibleProcedures.isNotEmpty) ...[
                const SizedBox(height: 10),
                // ── Mini procedure chips ────────────────────────────
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: visibleProcedures.map((proc) {
                    final name = CategoryProceduresData.localizedName(
                      proc,
                      locale,
                    );
                    return _MiniChip(
                      label: name,
                      color: category.accentColor,
                      onTap: () =>
                          onProcedureTap(proc['slug'] as String),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny, tappable procedure chip inside the category card.
class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.12),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
