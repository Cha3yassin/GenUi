import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Info card — "Avant de commencer" section displayed as clean icon+sentence rows.
class InfoCardBlockWidget extends StatelessWidget {
  const InfoCardBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Information';
    final body = data['body'] as String? ?? '';

    // Parse body into individual items (split by newline or bullet points)
    final items = body
        .split(RegExp(r'\n|(?=- )'))
        .map((s) => s.replaceFirst(RegExp(r'^-\s*'), '').trim())
        .where((s) => s.isNotEmpty)
        .take(4) // Max 4 clean rows
        .toList();

    // Icons for each prerequisite row
    const itemIcons = [
      Icons.info_outline_rounded,
      Icons.warning_amber_rounded,
      Icons.checklist_rounded,
      Icons.timer_outlined,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with main icon
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconFromName(data['icon'] as String?),
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Clean rows with small icon + one concise sentence each
            if (items.isNotEmpty)
              ...items.asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        itemIcons[idx % itemIcons.length],
                        size: 18,
                        color: AppTheme.mutedInk.withOpacity(0.6),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  IconData _iconFromName(String? iconName) {
    return switch (iconName) {
      'shield' => Icons.verified_user_rounded,
      'passport' => Icons.badge_rounded,
      'business' => Icons.business_center_rounded,
      _ => Icons.info_rounded,
    };
  }
}
