import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_providers.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/route_paths.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/async_value_widget.dart';
import '../../shared/models/category_model.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/sahil_chip_button.dart';
import '../../shared/widgets/sahil_search_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../history/history_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesValue = ref.watch(categoriesProvider);
    final locale = ref.watch(localeProvider);
    final isRtl = locale == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        drawer: const HistoryDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(locale: locale),
                const SizedBox(height: 28),

                // ── Hero section ────────────────────────────────────────
                _HeroSection(locale: locale),
                const SizedBox(height: 28),

                // ── Search bar ──────────────────────────────────────────
                SahilSearchBar(
                  hintText: AppStrings.get('search_hint', locale),
                  readOnly: true,
                  onTap: () => context.push(RoutePaths.search),
                ),
                const SizedBox(height: 32),

                // ── Categories ──────────────────────────────────────────
                SectionHeader(
                  title: AppStrings.get('browse_by_category', locale),
                  subtitle: AppStrings.get('category_subtitle', locale),
                ),
                const SizedBox(height: 16),
                AsyncValueWidget<List<CategoryModel>>(
                  value: categoriesValue,
                  data: (categories) =>
                      _CategoryGrid(categories: categories, locale: locale),
                ),
                const SizedBox(height: 36),

                // ── Popular chips ───────────────────────────────────────
                SectionHeader(
                  title: AppStrings.get('popular_this_week', locale),
                  subtitle: AppStrings.get('popular_subtitle', locale),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SahilChipButton(
                      label: AppStrings.get('buy_car', locale),
                      icon: Icons.directions_car_rounded,
                      onPressed: () =>
                          context.push(RoutePaths.procedure('buy-used-car')),
                    ),
                    SahilChipButton(
                      label: AppStrings.get('passport_renewal', locale),
                      icon: Icons.badge_rounded,
                      onPressed: () => context
                          .push(RoutePaths.procedure('passport-renewal')),
                    ),
                    SahilChipButton(
                      label: AppStrings.get('register_company', locale),
                      icon: Icons.business_center_rounded,
                      onPressed: () => context
                          .push(RoutePaths.procedure('register-company')),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Trust card ──────────────────────────────────────────
                _TrustCard(locale: locale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header with menu, brand, language toggle, and auth action ─────────────────

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Row(
      children: [
        // Hamburger
        Builder(
          builder: (ctx) => Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.paper,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, size: 20),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              padding: EdgeInsets.zero,
              tooltip: 'Menu',
            ),
          ),
        ),
        const Spacer(),

        // Language toggle
        _LanguageToggle(locale: locale),
        const SizedBox(width: 10),

        // Auth action
        if (authState.isAuthenticated)
          _UserAvatar(email: authState.user!.email)
        else
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.terracotta,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => context.push(RoutePaths.login),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                textStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(AppStrings.get('sign_in', locale)),
            ),
          ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.terracotta.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.terracotta.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.terracotta,
          ),
        ),
      ),
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('app_name', locale),
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.get('app_tagline', locale),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mutedInk,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

// ── Language toggle ───────────────────────────────────────────────────────────

class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangChip(
            label: 'AR',
            isActive: locale == 'ar',
            onTap: () => ref.read(localeProvider.notifier).setLocale('ar'),
          ),
          _LangChip(
            label: 'EN',
            isActive: locale == 'en',
            onTap: () => ref.read(localeProvider.notifier).setLocale('en'),
          ),
          _LangChip(
            label: 'FR',
            isActive: locale == 'fr',
            onTap: () => ref.read(localeProvider.notifier).setLocale('fr'),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.terracotta : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : AppTheme.mutedInk.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ── Category grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.locale});

  final List<CategoryModel> categories;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          locale: locale,
          onTap: () =>
              context.push(RoutePaths.categoryProcedures(category.id)),
        );
      },
    );
  }
}

// ── Trust card ────────────────────────────────────────────────────────────────

class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.olive.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: AppTheme.olive,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('trust_title', locale),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get('trust_body', locale),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
