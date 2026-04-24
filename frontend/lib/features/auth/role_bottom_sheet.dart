import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/genui/profile_config.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';

/// Bottom sheet to select user role before sign-in.
/// Returns 'individual' or 'enterprise', or null if dismissed.
class RoleBottomSheet extends ConsumerWidget {
  const RoleBottomSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const RoleBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            // Title
            Text(
              AppStrings.get('choose_role', locale),
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              locale == 'ar'
                  ? 'حدد نوع الإجراءات التي تبحث عنها'
                  : locale == 'en'
                      ? 'Select the type of procedures you need'
                      : 'Sélectionnez le type de démarches recherchées',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Individual option
            _RoleOption(
              profile: ProfileType.individual,
              icon: Icons.person_rounded,
              title: AppStrings.get('individual', locale),
              subtitle: AppStrings.get('individual_desc', locale),
              onTap: () => Navigator.pop(context, 'individual'),
            ),
            const SizedBox(height: 12),

            // Enterprise option
            _RoleOption(
              profile: ProfileType.enterprise,
              icon: Icons.business_rounded,
              title: AppStrings.get('enterprise', locale),
              subtitle: AppStrings.get('enterprise_desc', locale),
              onTap: () => Navigator.pop(context, 'enterprise'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatefulWidget {
  const _RoleOption({
    required this.profile,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ProfileType profile;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_RoleOption> createState() => _RoleOptionState();
}

class _RoleOptionState extends State<_RoleOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = getThemeByProfile(widget.profile);
    final isEnterprise = widget.profile == ProfileType.enterprise;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: isEnterprise
          ? _EnterpriseRoleCard(
              theme: theme,
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.icon,
              isHovered: _isHovered,
              onTap: widget.onTap,
            )
          : _IndividualRoleCard(
              theme: theme,
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.icon,
              isHovered: _isHovered,
              onTap: widget.onTap,
            ),
    );
  }
}

class _IndividualRoleCard extends StatelessWidget {
  const _IndividualRoleCard({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isHovered,
    required this.onTap,
  });

  final ProfileThemeData theme;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isHovered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isHovered ? theme.surfaceTint : AppTheme.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHovered
              ? theme.accent.withValues(alpha: 0.28)
              : theme.borderTint,
          width: isHovered ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: theme.accent, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.accent.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnterpriseRoleCard extends StatelessWidget {
  const _EnterpriseRoleCard({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isHovered,
    required this.onTap,
  });

  final ProfileThemeData theme;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isHovered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHovered
              ? [
                  const Color(0xFF111B2E),
                  const Color(0xFF1E3154),
                  const Color(0xFF2F4B7C),
                ]
              : [
                  const Color(0xFF172033),
                  const Color(0xFF243B63),
                  const Color(0xFF2F4B7C),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.professionalAccent.withValues(
            alpha: isHovered ? 0.42 : 0.26,
          ),
          width: isHovered ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accent.withValues(alpha: isHovered ? 0.22 : 0.14),
            blurRadius: isHovered ? 26 : 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.professionalAccent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.professionalAccent.withValues(alpha: 0.26),
                    ),
                  ),
                  child: Icon(icon, color: theme.professionalAccent, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              'Pro',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: theme.professionalAccent,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: theme.heroMutedForeground,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.professionalAccent.withValues(alpha: 0.88),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
