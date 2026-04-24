import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';
import '../../shared/widgets/section_header.dart';

class SectionTitleBlockWidget extends ConsumerWidget {
  const SectionTitleBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(effectiveProfileProvider);
    final theme = getThemeByProfile(profile);
    final isEnterprise = profile == ProfileType.enterprise;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEnterprise) ...[
            Container(
              width: 5,
              height: 54,
              decoration: BoxDecoration(
                color: theme.professionalAccent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SectionHeader(
              title: data['title'] as String? ?? '',
              subtitle: data['subtitle'] as String?,
            ),
          ),
        ],
      ),
    );
  }
}
