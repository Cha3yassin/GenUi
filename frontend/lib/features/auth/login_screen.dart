import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_models.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/route_paths.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import 'role_bottom_sheet.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Redirect on authentication
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isAuthenticated) {
        context.go(RoutePaths.home);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.sand,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: size.width > 480 ? 420 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // ── Decorative top accent ─────────────────────────────
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.terracotta.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Logo mark ─────────────────────────────────────────
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppTheme.paper,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.terracotta.withOpacity(0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Fb',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.terracotta,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── App name ──────────────────────────────────────────
                  Text(
                    AppStrings.get('app_name', locale),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Tagline ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppStrings.get('app_tagline', locale),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mutedInk.withOpacity(0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 44),

                  // ── Error message ─────────────────────────────────────
                  if (authState.error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8B4AE),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 18, color: Color(0xFFB3261E)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFB3261E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Google Sign In button ─────────────────────────────
                  _GoogleSignInButton(
                    isLoading: authState.isLoading,
                    locale: locale,
                    onPressed: () => _handleSignIn(context, ref),
                  ),
                  const SizedBox(height: 14),

                  // ── Skip button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => context.go(RoutePaths.home),
                      child: Text(
                        locale == 'ar'
                            ? 'متابعة بدون حساب'
                            : locale == 'en'
                                ? 'Continue without account'
                                : 'Continuer sans compte',
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Divider ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.borderLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          locale == 'ar'
                              ? 'أو'
                              : locale == 'en'
                                  ? 'or'
                                  : 'ou',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedInk.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.borderLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Trust message ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.paper,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.olive.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 20,
                            color: AppTheme.olive,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            locale == 'ar'
                                ? 'بياناتك محمية ولن تُشارك مع أي جهة خارجية.'
                                : locale == 'en'
                                    ? 'Your data is protected and never shared with third parties.'
                                    : 'Vos données sont protégées et jamais partagées.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.mutedInk,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignIn(BuildContext context, WidgetRef ref) async {
    final role = await RoleBottomSheet.show(context);
    if (role == null) return;
    ref.read(authProvider.notifier).login(role);
  }
}

/// Custom Google Sign-In button — premium feel, not generic.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.locale,
    required this.onPressed,
  });

  final bool isLoading;
  final String locale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.terracotta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google "G" icon
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.terracotta,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.get('sign_in_with_google', locale),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
