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

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isEnterprise ? const Color(0xFF101828) : null,
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
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 860
                ? 3
                : constraints.maxWidth >= 520
                    ? 2
                    : 1;
            const spacing = 10.0;
            final itemWidth =
                (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                    crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: cards.map((card) {
                return SizedBox(
                  width: itemWidth,
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
  });

  final String title;
  final String subtitle;
  final String iconName;
  final String tone;
  final List<String> items;
  final ProfileThemeData theme;
  final bool isEnterprise;

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(isEnterprise ? 16 : 20),
        border: Border.all(color: theme.borderTint),
        boxShadow: [
          BoxShadow(
            color: theme.accent.withValues(alpha: isEnterprise ? 0.05 : 0.03),
            blurRadius: 14,
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
              height: 118,
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
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
