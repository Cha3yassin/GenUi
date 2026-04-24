import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_providers.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/route_paths.dart';
import '../../core/genui/profile_config.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';

class HistoryDrawer extends ConsumerWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;
    final profile = authState.isAuthenticated
        ? profileFromRole(authState.user!.role)
        : ProfileType.individual;
    final profileTheme = getThemeByProfile(profile);
    final isEnterprise = profile == ProfileType.enterprise;

    ref.invalidate(historySummariesProvider);

    return Drawer(
      backgroundColor: profileTheme.pageBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: BoxDecoration(
                gradient: isEnterprise
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: profileTheme.heroGradient,
                      )
                    : null,
                color: isEnterprise ? null : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: profileTheme.borderTint),
                boxShadow: isEnterprise
                    ? [
                        BoxShadow(
                          color: profileTheme.accent.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isEnterprise
                              ? profileTheme.professionalAccent
                              : profileTheme.accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEnterprise
                                ? profileTheme.professionalAccent.withValues(
                                    alpha: 0.28,
                                  )
                                : profileTheme.accent.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Fb',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: profileTheme.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get('app_name', locale),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isEnterprise
                                    ? profileTheme.heroForeground
                                    : AppTheme.ink,
                              ),
                            ),
                            if (authState.isAuthenticated) ...[
                              const SizedBox(height: 3),
                              Text(
                                authState.user!.email,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: isEnterprise
                                      ? profileTheme.heroMutedForeground
                                      : AppTheme.mutedInk,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (authState.isAuthenticated) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isEnterprise
                            ? Colors.white.withValues(alpha: 0.10)
                            : profileTheme.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEnterprise
                              ? Colors.white.withValues(alpha: 0.14)
                              : profileTheme.accent.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        AppStrings.get(authState.user!.role, locale),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isEnterprise
                              ? profileTheme.professionalAccent
                              : profileTheme.accent,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: profileTheme.borderTint),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppStrings.get('history', locale).toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isEnterprise
                      ? profileTheme.secondaryAccent.withValues(alpha: 0.60)
                      : AppTheme.mutedInk.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: authState.isAuthenticated
                  ? _HistoryList(
                      locale: locale,
                      profile: profile,
                      profileTheme: profileTheme,
                    )
                  : _SignInPrompt(
                      locale: locale,
                      profileTheme: profileTheme,
                    ),
            ),
            Divider(color: profileTheme.borderTint),
            if (authState.isAuthenticated)
              _DrawerAction(
                icon: Icons.logout_rounded,
                label: AppStrings.get('sign_out', locale),
                color: const Color(0xFFB3261E),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
              )
            else
              _DrawerAction(
                icon: Icons.login_rounded,
                label: AppStrings.get('sign_in', locale),
                color: profileTheme.accent,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.login);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, size: 20, color: color),
        title: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({
    required this.locale,
    required this.profileTheme,
  });

  final String locale;
  final ProfileThemeData profileTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: profileTheme.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 26,
                color: profileTheme.accent.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              locale == 'ar'
                  ? 'سجل دخولك لرؤية السجل'
                  : locale == 'en'
                      ? 'Sign in to view your history'
                      : 'Connectez-vous pour voir l\'historique',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedInk.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({
    required this.locale,
    required this.profile,
    required this.profileTheme,
  });

  final String locale;
  final ProfileType profile;
  final ProfileThemeData profileTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesValue = ref.watch(historySummariesProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(locale == 'ar' ? 'ar' : locale);
    final isEnterprise = profile == ProfileType.enterprise;

    return summariesValue.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Center(
        child: Text(
          AppStrings.get('error_generic', locale),
          style: theme.textTheme.bodyMedium,
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (isEnterprise
                              ? profileTheme.secondaryAccent
                              : AppTheme.olive)
                          .withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      size: 24,
                      color: (isEnterprise
                              ? profileTheme.secondaryAccent
                              : AppTheme.olive)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.get('no_history', locale),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedInk.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: isEnterprise ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(isEnterprise ? 14 : 12),
                border: Border.all(
                  color: isEnterprise
                      ? profileTheme.borderTint
                      : Colors.transparent,
                ),
              ),
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isEnterprise ? 14 : 12),
                ),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isEnterprise
                        ? profileTheme.secondaryAccent.withValues(alpha: 0.08)
                        : AppTheme.terracotta.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.article_rounded,
                    size: 18,
                    color: isEnterprise
                        ? profileTheme.secondaryAccent
                        : AppTheme.terracotta.withValues(alpha: 0.5),
                  ),
                ),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isEnterprise ? const Color(0xFF101828) : AppTheme.ink,
                    fontWeight:
                        isEnterprise ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  dateFormat.format(item.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isEnterprise ? const Color(0xFF667085) : null,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.historyDetail(item.id));
                },
              ),
            );
          },
        );
      },
    );
  }
}
