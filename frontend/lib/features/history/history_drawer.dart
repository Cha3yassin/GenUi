import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_providers.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/route_paths.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';

class HistoryDrawer extends ConsumerWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Invalidate history cache each time drawer opens — ensures fresh data
    ref.invalidate(historySummariesProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Branding header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('app_name', locale),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                        if (authState.isAuthenticated) ...[
                          const SizedBox(height: 2),
                          Text(
                            authState.user!.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
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
            ),

            const SizedBox(height: 16),
            const Divider(),

            // ── History title ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppStrings.get('history', locale).toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.mutedInk.withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // ── History list ────────────────────────────────────────
            Expanded(
              child: authState.isAuthenticated
                  ? _HistoryList(locale: locale)
                  : _SignInPrompt(locale: locale),
            ),

            // ── Footer actions ──────────────────────────────────────
            const Divider(),
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
                color: AppTheme.terracotta,
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
          style: GoogleFonts.plusJakartaSans(
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
  const _SignInPrompt({required this.locale});

  final String locale;

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
                color: AppTheme.terracotta.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 26,
                color: AppTheme.terracotta.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('sign_in_for_history', locale),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedInk.withOpacity(0.6),
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
  const _HistoryList({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesValue = ref.watch(historySummariesProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(locale == 'ar' ? 'ar' : locale);

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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.olive.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      size: 22,
                      color: AppTheme.olive.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.get('no_history', locale),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedInk.withOpacity(0.5),
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
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.terracotta.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.article_rounded,
                    size: 16, color: AppTheme.terracotta.withOpacity(0.5)),
              ),
              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                dateFormat.format(item.createdAt),
                style: theme.textTheme.labelSmall,
              ),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.historyDetail(item.id));
              },
            );
          },
        );
      },
    );
  }
}
