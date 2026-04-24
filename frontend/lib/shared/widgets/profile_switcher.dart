import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';
import '../../core/theme/app_theme.dart';

class ProfileSwitcher extends ConsumerWidget {
  const ProfileSwitcher({
    required this.locale,
    this.showLockHint = true,
    super.key,
  });

  final String locale;
  final bool showLockHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(effectiveProfileProvider);
    final locked = ref.watch(profileLockedProvider);
    final theme = getThemeByProfile(profile);

    if (locked) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
              profile == ProfileType.enterprise ? 16 : 18),
          border: Border.all(color: theme.borderTint),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LockedProfileChip(
              title: activeProfileTitle(profile, locale),
              subtitle: activeProfileSubtitle(profile, locale),
              icon: activeProfileIcon(profile),
              accent: theme.accent,
              isEnterprise: profile == ProfileType.enterprise,
            ),
            if (showLockHint) ...[
              const SizedBox(height: 8),
              Text(
                'Profil verrouille par la connexion active.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedInk,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderTint),
      ),
      child: Row(
        children: [
          _ProfileChip(
            label: profileLabel(ProfileType.individual, locale),
            isActive: profile == ProfileType.individual,
            accent: getThemeByProfile(ProfileType.individual).accent,
            onTap: () {
              ref.read(selectedProfileProvider.notifier).state =
                  ProfileType.individual;
            },
          ),
          const SizedBox(width: 8),
          _ProfileChip(
            label: '${profileLabel(ProfileType.enterprise, locale)} / Pro',
            isActive: profile == ProfileType.enterprise,
            accent: getThemeByProfile(ProfileType.enterprise).accent,
            onTap: () {
              ref.read(selectedProfileProvider.notifier).state =
                  ProfileType.enterprise;
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.label,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? accent : AppTheme.borderLight,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isActive ? Colors.white : AppTheme.ink,
                ),
          ),
        ),
      ),
    );
  }
}

class _LockedProfileChip extends StatelessWidget {
  const _LockedProfileChip({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.isEnterprise,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool isEnterprise;

  @override
  Widget build(BuildContext context) {
    if (isEnterprise) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFD6A94A),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: const Color(0xFF101828),
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFD6A94A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color:
                                const Color(0xFFD6A94A).withValues(alpha: 0.28),
                          ),
                        ),
                        child: Text(
                          'Professionnel',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFF8C6A1D),
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Parcours optimise pour les demarches d entreprise',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF667085),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: accent,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.lock_rounded,
              size: 18,
              color: accent.withValues(alpha: 0.8),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEnterprise
              ? [accent, accent.withValues(alpha: 0.88)]
              : [accent.withValues(alpha: 0.92), accent],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}
