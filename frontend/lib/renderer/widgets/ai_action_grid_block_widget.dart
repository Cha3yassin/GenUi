import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';

class AiActionGridBlockWidget extends ConsumerWidget {
  const AiActionGridBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(effectiveProfileProvider);
    final theme = getThemeByProfile(profile);
    final isEnterprise = profile == ProfileType.enterprise;
    final title = data['title'] as String? ?? '';
    final subtitle = data['subtitle'] as String? ?? '';
    final cards = (data['cards'] as List<dynamic>? ?? []).cast<Map>();
    final semanticId = data['semanticId'] as String? ?? 'general_admin';
    final semanticLabel = data['semanticLabel'] as String? ?? '';
    final semanticLayout = data['semanticLayout'] as String? ?? 'balanced';
    final semanticStyle = _semanticStyle(semanticId);

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF101828),
              ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF667085),
                ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SemanticChip(
              label: semanticLabel,
              background: semanticStyle.accent.withValues(alpha: 0.10),
              foreground: semanticStyle.accent,
              border: semanticStyle.border,
            ),
            _SemanticChip(
              label: _layoutLabel(semanticLayout),
              background: semanticStyle.secondary.withValues(alpha: 0.10),
              foreground: semanticStyle.secondary,
              border: semanticStyle.border,
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final defaultColumns = constraints.maxWidth >= 860
                ? 3
                : constraints.maxWidth >= 520
                    ? 2
                    : 1;
            final standardItemWidth =
                (constraints.maxWidth - (spacing * (defaultColumns - 1))) /
                    defaultColumns;
            final highlightWidth = constraints.maxWidth;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: cards.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                final isFeatured = _isFeaturedCard(
                  semanticLayout: semanticLayout,
                  index: index,
                  width: constraints.maxWidth,
                );

                return SizedBox(
                  width: isFeatured ? highlightWidth : standardItemWidth,
                  child: _AdaptiveActionCard(
                    title: card['title']?.toString() ?? '',
                    subtitle: card['subtitle']?.toString() ?? '',
                    iconName: card['icon']?.toString() ?? 'route',
                    tone: card['tone']?.toString() ?? 'secondary',
                    items: (card['items'] as List<dynamic>? ?? [])
                        .map((item) => item.toString())
                        .where((item) => item.isNotEmpty)
                        .toList(),
                    theme: theme,
                    isEnterprise: isEnterprise,
                    semanticStyle: semanticStyle,
                    isFeatured: isFeatured,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AdaptiveActionCard extends StatelessWidget {
  const _AdaptiveActionCard({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.tone,
    required this.items,
    required this.theme,
    required this.isEnterprise,
    required this.semanticStyle,
    required this.isFeatured,
  });

  final String title;
  final String subtitle;
  final String iconName;
  final String tone;
  final List<String> items;
  final ProfileThemeData theme;
  final bool isEnterprise;
  final _SemanticStyle semanticStyle;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      'professional' => theme.professionalAccent,
      'success' => theme.successAccent,
      'primary' => theme.accent,
      _ => theme.secondaryAccent,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFeatured
              ? [
                  semanticStyle.surface,
                  Colors.white,
                ]
              : [
                  Colors.white,
                  semanticStyle.surface.withValues(alpha: 0.55),
                ],
        ),
        borderRadius: BorderRadius.circular(isEnterprise ? 16 : 20),
        border: Border.all(color: semanticStyle.border),
        boxShadow: [
          BoxShadow(
            color: semanticStyle.accent.withValues(
              alpha: isFeatured ? 0.10 : (isEnterprise ? 0.06 : 0.04),
            ),
            blurRadius: isFeatured ? 18 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEnterprise) ...[
            Container(
              width: 4,
              height: isFeatured ? 138 : 118,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconFromName(iconName), color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: const Color(0xFF101828),
                                  fontWeight: isFeatured
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF667085),
                                      height: 1.4,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: const Color(0xFF183153),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                if (isFeatured) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Composition GenUI priorisee',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: semanticStyle.secondary,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFromName(String iconName) {
    return switch (iconName) {
      'folder' => Icons.folder_open_rounded,
      'wallet' => Icons.account_balance_wallet_rounded,
      'office' => Icons.account_balance_rounded,
      _ => Icons.route_rounded,
    };
  }
}

class _SemanticChip extends StatelessWidget {
  const _SemanticChip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
            ),
      ),
    );
  }
}

bool _isFeaturedCard({
  required String semanticLayout,
  required int index,
  required double width,
}) {
  if (width < 520) {
    return false;
  }

  return switch (semanticLayout) {
    'featured_budget' => index == 0,
    'dossier_first' => index == 0,
    'compact_workflow' => index == 0,
    'dashboard_launch' => index < 2 && width >= 860,
    _ => false,
  };
}

String _layoutLabel(String layout) {
  return switch (layout) {
    'featured_budget' => 'Budget hero',
    'dossier_first' => 'Dossier central',
    'compact_workflow' => 'Workflow prioritaire',
    'dashboard_launch' => 'Vue pilotage',
    _ => 'Vue adaptive',
  };
}

class _SemanticStyle {
  const _SemanticStyle({
    required this.accent,
    required this.secondary,
    required this.surface,
    required this.border,
  });

  final Color accent;
  final Color secondary;
  final Color surface;
  final Color border;
}

_SemanticStyle _semanticStyle(String semanticId) {
  return switch (semanticId) {
    'legal_transfer' => const _SemanticStyle(
        accent: Color(0xFF8B5E3C),
        secondary: Color(0xFF355C7D),
        surface: Color(0xFFF8F2ED),
        border: Color(0xFFE5D4C7),
      ),
    'acquisition' => const _SemanticStyle(
        accent: Color(0xFF0E7490),
        secondary: Color(0xFF155E75),
        surface: Color(0xFFEFF9FC),
        border: Color(0xFFCBE8EF),
      ),
    'renewal' => const _SemanticStyle(
        accent: Color(0xFF2563EB),
        secondary: Color(0xFF1D4ED8),
        surface: Color(0xFFF1F6FF),
        border: Color(0xFFCFE0FF),
      ),
    'business_launch' => const _SemanticStyle(
        accent: Color(0xFFD6A94A),
        secondary: Color(0xFF2F4B7C),
        surface: Color(0xFFF8F4EA),
        border: Color(0xFFE8D8AF),
      ),
    _ => const _SemanticStyle(
        accent: Color(0xFF4F46E5),
        secondary: Color(0xFF334155),
        surface: Color(0xFFF5F7FB),
        border: Color(0xFFD9E1EE),
      ),
  };
}
