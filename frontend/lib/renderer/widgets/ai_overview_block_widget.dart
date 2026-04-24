import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';

class AiOverviewBlockWidget extends ConsumerWidget {
  const AiOverviewBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(effectiveProfileProvider);
    final theme = getThemeByProfile(profile);
    final isEnterprise = profile == ProfileType.enterprise;
    final title = data['title'] as String? ?? '';
    final summary = data['summary'] as String? ?? '';
    final semanticLabel = data['semanticLabel'] as String? ?? '';
    final semanticHint = data['semanticHint'] as String? ?? '';
    final semanticId = data['semanticId'] as String? ?? 'general_admin';
    final semanticLayout = data['semanticLayout'] as String? ?? 'balanced';
    final semanticLayoutLabel = data['semanticLayoutLabel'] as String?;
    final semanticIconCode = data['semanticIcon'] as int?;
    final metrics = (data['metrics'] as List<dynamic>? ?? []).cast<Map>();
    final highlights =
        (data['highlights'] as List<dynamic>? ?? []).cast<String>();
    final semanticStyle = _semanticStyle(semanticId);
    final semanticIcon = semanticIconCode == null
        ? semanticStyle.fallbackIcon
        : IconData(
            semanticIconCode,
            fontFamily: 'MaterialIcons',
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            semanticStyle.surface,
            isEnterprise
                ? Colors.white
                : semanticStyle.surface.withValues(alpha: 0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(isEnterprise ? 18 : 22),
        border: Border.all(color: semanticStyle.border),
        boxShadow: [
          BoxShadow(
            color: semanticStyle.accent.withValues(alpha: 0.08),
            blurRadius: isEnterprise ? 18 : 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isEnterprise ? 0.80 : 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: semanticStyle.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: semanticStyle.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(semanticIcon, color: semanticStyle.accent),
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
                          _SemanticBadge(
                            label: semanticLabel,
                            background: semanticStyle.accent.withValues(
                              alpha: 0.10,
                            ),
                            foreground: semanticStyle.accent,
                            border: semanticStyle.border,
                          ),
                          _SemanticBadge(
                            label:
                                semanticLayoutLabel ??
                                _layoutLabel(semanticLayout),
                            background: semanticStyle.secondary.withValues(
                              alpha: 0.10,
                            ),
                            foreground: semanticStyle.secondary,
                            border: semanticStyle.border,
                          ),
                        ],
                      ),
                      if (semanticHint.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          semanticHint,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF667085),
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF101828),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isEnterprise ? const Color(0xFF667085) : null,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: metrics.map((metric) {
              return _MetricPill(
                label: metric['label']?.toString() ?? '',
                value: metric['value']?.toString() ?? '',
                tone: metric['tone']?.toString() ?? 'secondary',
                theme: theme,
                semanticStyle: semanticStyle,
              );
            }).toList(),
          ),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: highlights.map((highlight) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: isEnterprise ? 0.88 : 1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: semanticStyle.border),
                  ),
                  child: Text(
                    highlight,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: semanticStyle.secondary,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.tone,
    required this.theme,
    required this.semanticStyle,
  });

  final String label;
  final String value;
  final String tone;
  final ProfileThemeData theme;
  final _SemanticStyle semanticStyle;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      'professional' => theme.professionalAccent,
      'success' => theme.successAccent,
      'primary' => theme.accent,
      _ => theme.secondaryAccent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: semanticStyle.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF667085),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _SemanticBadge extends StatelessWidget {
  const _SemanticBadge({
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

String _layoutLabel(String layout) {
  return switch (layout) {
    'featured_budget' => 'Budget mis en avant',
    'dossier_first' => 'Dossier en premier',
    'compact_workflow' => 'Workflow compact',
    'dashboard_launch' => 'Pilotage',
    _ => 'Vue equilibree',
  };
}

class _SemanticStyle {
  const _SemanticStyle({
    required this.accent,
    required this.secondary,
    required this.surface,
    required this.border,
    required this.fallbackIcon,
  });

  final Color accent;
  final Color secondary;
  final Color surface;
  final Color border;
  final IconData fallbackIcon;
}

_SemanticStyle _semanticStyle(String semanticId) {
  return switch (semanticId) {
    'legal_transfer' => const _SemanticStyle(
        accent: Color(0xFF8B5E3C),
        secondary: Color(0xFF355C7D),
        surface: Color(0xFFF8F2ED),
        border: Color(0xFFE5D4C7),
        fallbackIcon: Icons.compare_arrows_rounded,
      ),
    'acquisition' => const _SemanticStyle(
        accent: Color(0xFF0E7490),
        secondary: Color(0xFF155E75),
        surface: Color(0xFFEFF9FC),
        border: Color(0xFFCBE8EF),
        fallbackIcon: Icons.shopping_bag_rounded,
      ),
    'renewal' => const _SemanticStyle(
        accent: Color(0xFF2563EB),
        secondary: Color(0xFF1D4ED8),
        surface: Color(0xFFF1F6FF),
        border: Color(0xFFCFE0FF),
        fallbackIcon: Icons.autorenew_rounded,
      ),
    'business_launch' => const _SemanticStyle(
        accent: Color(0xFFD6A94A),
        secondary: Color(0xFF2F4B7C),
        surface: Color(0xFFF8F4EA),
        border: Color(0xFFE8D8AF),
        fallbackIcon: Icons.rocket_launch_rounded,
      ),
    _ => const _SemanticStyle(
        accent: Color(0xFF4F46E5),
        secondary: Color(0xFF334155),
        surface: Color(0xFFF5F7FB),
        border: Color(0xFFD9E1EE),
        fallbackIcon: Icons.account_tree_rounded,
      ),
  };
}
