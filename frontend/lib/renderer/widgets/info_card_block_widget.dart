import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';
import '../../core/locale/locale_provider.dart';

class InfoCardBlockWidget extends ConsumerWidget {
  const InfoCardBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = data['title'] as String? ?? 'Information';
    final body = data['body'] as String? ?? '';
    final profile = ref.watch(effectiveProfileProvider);
    final locale = ref.watch(localeProvider);
    final theme = getThemeByProfile(profile);
    final isEnterprise = profile == ProfileType.enterprise;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isEnterprise ? 18 : 22),
        border: Border.all(color: theme.borderTint),
        boxShadow: [
          BoxShadow(
            color: theme.accent.withValues(alpha: isEnterprise ? 0.06 : 0.04),
            blurRadius: isEnterprise ? 18 : 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEnterprise) ...[
              Container(
                width: 5,
                height: 112,
                decoration: BoxDecoration(
                  color: theme.professionalAccent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isEnterprise
                    ? theme.secondaryAccent.withValues(alpha: 0.08)
                    : theme.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _iconFromName(data['icon'] as String?),
                color: isEnterprise ? theme.secondaryAccent : theme.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEnterprise)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surfaceTint,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.borderTint),
                      ),
                      child: Text(
                        locale == 'ar'
                            ? 'قبل الإجراء'
                            : locale == 'en'
                                ? 'Before action'
                                : 'Avant action',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: theme.secondaryAccent,
                            ),
                      ),
                    ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isEnterprise ? const Color(0xFF101828) : null,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isEnterprise ? const Color(0xFF667085) : null,
                          height: 1.55,
                        ),
                  ),
                ],
              ),
            ),
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
