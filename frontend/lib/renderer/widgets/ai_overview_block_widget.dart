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
    final metrics = (data['metrics'] as List<dynamic>? ?? []).cast<Map>();
    final highlights =
        (data['highlights'] as List<dynamic>? ?? []).cast<String>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isEnterprise ? theme.surfaceTint : Colors.white,
        borderRadius: BorderRadius.circular(isEnterprise ? 18 : 22),
        border: Border.all(color: theme.borderTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isEnterprise ? const Color(0xFF101828) : null,
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
                        Colors.white.withValues(alpha: isEnterprise ? 0.75 : 1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: theme.borderTint),
                  ),
                  child: Text(
                    highlight,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isEnterprise
                              ? theme.secondaryAccent
                              : theme.accent,
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
  });

  final String label;
  final String value;
  final String tone;
  final ProfileThemeData theme;

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
        border: Border.all(color: color.withValues(alpha: 0.14)),
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
