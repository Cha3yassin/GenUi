import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_providers.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/route_paths.dart';
import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';
import '../../core/genui/procedure_config.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/async_value_widget.dart';
import '../../shared/models/category_model.dart';
import '../../shared/widgets/animated_reveal.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/contextual_header.dart';
import '../../shared/widgets/profile_switcher.dart';
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
    final profile = ref.watch(effectiveProfileProvider);
    final profileContent = getProfileContent(profile);
    final profileTheme = getThemeByProfile(profile);
    final uiVariant = getProfileUiVariant(profile);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: profileTheme.pageBackground,
        drawer: const HistoryDrawer(),
        body: SafeArea(
          child: Container(
            color: profileTheme.pageBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(locale: locale),
                  const SizedBox(height: 24),
                  AnimatedReveal(
                    child: _ProfileHero(
                      locale: locale,
                      profile: profile,
                      content: profileContent,
                      theme: profileTheme,
                      uiVariant: uiVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 60),
                    child: ProfileSwitcher(locale: locale),
                  ),
                  const SizedBox(height: 24),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 120),
                    child: _SearchPanel(
                      locale: locale,
                      profile: profile,
                      content: profileContent,
                      theme: profileTheme,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 180),
                    child: _RecommendedProceduresSection(
                      locale: locale,
                      profile: profile,
                      content: profileContent,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 240),
                    child: SectionHeader(
                      title: profileContent.categoriesTitleText(locale),
                      subtitle: profileContent.categoriesSubtitleText(locale),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AsyncValueWidget<List<CategoryModel>>(
                    value: categoriesValue,
                    data: (categories) => _CategoryGrid(
                      categories: categories,
                      locale: locale,
                      profile: profile,
                    ),
                  ),
                  const SizedBox(height: 36),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 320),
                    child: _TrustCard(
                      title: profileContent.trustTitleText(locale),
                      body: profileContent.trustBodyText(locale),
                      theme: profileTheme,
                      profile: profile,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedProceduresSection extends StatelessWidget {
  const _RecommendedProceduresSection({
    required this.locale,
    required this.profile,
    required this.content,
  });

  final String locale;
  final ProfileType profile;
  final ProfileContent content;

  @override
  Widget build(BuildContext context) {
    final uiVariant = getProfileUiVariant(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: content.recommendationsTitleText(locale),
          subtitle: content.recommendationsSubtitleText(locale),
        ),
        const SizedBox(height: 14),
        if (uiVariant.prioritySectionVariant == PrioritySectionVariant.chips)
          _PersonalPriorityChips(locale: locale, profile: profile)
        else
          const _EnterprisePriorityGrid(),
      ],
    );
  }
}

class _PersonalPriorityChips extends StatelessWidget {
  const _PersonalPriorityChips({required this.locale, required this.profile});

  final String locale;
  final ProfileType profile;

  @override
  Widget build(BuildContext context) {
    final recommended = getRecommendedProcedures(profile);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: recommended.map((slug) {
        return SahilChipButton(
          label: procedureLabel(slug, locale),
          onPressed: () => context.push(RoutePaths.procedure(slug)),
          icon: Icons.auto_awesome_rounded,
        );
      }).toList(),
    );
  }
}

class _EnterprisePriorityGrid extends StatelessWidget {
  const _EnterprisePriorityGrid();

  @override
  Widget build(BuildContext context) {
    const groups = [
      _EnterpriseActionGroup(
        title: 'Creer ou modifier une societe',
        description: 'Registre, immatriculation et pieces de lancement.',
        icon: Icons.apartment_rounded,
        accent: Color(0xFFD6A94A),
        items: ['Creer SARL', 'Inscription RNE', 'Patente'],
      ),
      _EnterpriseActionGroup(
        title: 'Obligations fiscales',
        description: 'Suivi des taxes, declarations et conformite fiscale.',
        icon: Icons.receipt_long_rounded,
        accent: Color(0xFF2F4B7C),
        items: ['TVA', 'Declaration fiscale', 'Quitus fiscal'],
      ),
      _EnterpriseActionGroup(
        title: 'Obligations sociales',
        description: 'Couverture sociale et organismes obligatoires.',
        icon: Icons.assured_workload_rounded,
        accent: Color(0xFF2E7D5B),
        items: ['CNSS', 'CNAM', 'Retraite'],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1080
            ? 3
            : constraints.maxWidth >= 680
                ? 2
                : 1;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: groups.map((group) {
            return SizedBox(
              width: itemWidth,
              child: _EnterpriseActionGroupCard(group: group),
            );
          }).toList(),
        );
      },
    );
  }
}

class _EnterpriseActionGroup {
  const _EnterpriseActionGroup({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final List<String> items;
}

class _EnterpriseActionGroupCard extends StatelessWidget {
  const _EnterpriseActionGroupCard({required this.group});

  final _EnterpriseActionGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DEE8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172033).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 162,
            decoration: BoxDecoration(
              color: group.accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: group.accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(group.icon, color: group.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: const Color(0xFF101828),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            group.description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF667085),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: group.accent.withValues(alpha: 0.10), height: 1),
                const SizedBox(height: 12),
                ...group.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: group.accent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: group.accent,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => context.push(RoutePaths.search),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Consulter',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: group.accent,
                        ),
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

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.locale,
    required this.profile,
    required this.content,
    required this.theme,
  });

  final String locale;
  final ProfileType profile;
  final ProfileContent content;
  final ProfileThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (profile == ProfileType.enterprise) {
      final filters = getQuickFilters(profile, locale);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.borderTint),
          boxShadow: [
            BoxShadow(
              color: theme.accent.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.searchTitleText(locale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: theme.accent,
                  ),
            ),
            const SizedBox(height: 12),
            SahilSearchBar(
              hintText: content.searchHintText(locale),
              accentColor: theme.accent,
              variant: SahilSearchBarVariant.professional,
              readOnly: true,
              onTap: () => context.push(RoutePaths.search),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: filters.map((filter) {
                return InkWell(
                  onTap: () => context.push(RoutePaths.search),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.borderTint),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter.icon,
                          size: 16,
                          color: theme.professionalAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          filter.label,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: theme.accent,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    return SahilSearchBar(
      hintText: content.searchHintText(locale),
      contextLabel: content.searchTitleText(locale),
      accentColor: theme.accent,
      readOnly: true,
      onTap: () => context.push(RoutePaths.search),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Row(
      children: [
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
        _LanguageToggle(locale: locale),
        const SizedBox(width: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
        color: AppTheme.terracotta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.terracotta.withValues(alpha: 0.2)),
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
            color: isActive
                ? Colors.white
                : AppTheme.mutedInk.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.locale,
    required this.profile,
  });

  final List<CategoryModel> categories;
  final String locale;
  final ProfileType profile;

  @override
  Widget build(BuildContext context) {
    const spacing = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 360
                ? 2
                : 1;
        final itemWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return AnimatedReveal(
              delay: Duration(milliseconds: 60 * index),
              child: SizedBox(
                width: itemWidth,
                child: CategoryCard(
                  category: category,
                  locale: locale,
                  profileType: profile,
                  isFeatured: index < 3,
                  onTap: () =>
                      context.push(RoutePaths.categoryProcedures(category.id)),
                  onProcedureTap: (slug) =>
                      context.push(RoutePaths.procedure(slug)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.title,
    required this.body,
    required this.theme,
    required this.profile,
  });

  final String title;
  final String body;
  final ProfileThemeData theme;
  final ProfileType profile;

  @override
  Widget build(BuildContext context) {
    if (profile == ProfileType.enterprise) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.borderTint),
          boxShadow: [
            BoxShadow(
              color: theme.accent.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.secondaryAccent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.fact_check_rounded,
                color: theme.secondaryAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: theme.accent,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF667085),
                          height: 1.45,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderTint),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.fact_check_rounded,
              color: theme.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  body,
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

class _HeroGlyph extends StatelessWidget {
  const _HeroGlyph({required this.theme, required this.profile});

  final ProfileThemeData theme;
  final ProfileType profile;

  @override
  Widget build(BuildContext context) {
    if (profile == ProfileType.enterprise) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: theme.professionalAccent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.professionalAccent.withValues(alpha: 0.32),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.business_center_rounded,
          color: theme.accent,
          size: 30,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        profile == ProfileType.enterprise
            ? Icons.business_center_rounded
            : Icons.person_search_rounded,
        color: theme.accent,
        size: 28,
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.locale,
    required this.profile,
    required this.content,
    required this.theme,
    required this.uiVariant,
  });

  final String locale;
  final ProfileType profile;
  final ProfileContent content;
  final ProfileThemeData theme;
  final ProfileUiVariant uiVariant;

  @override
  Widget build(BuildContext context) {
    if (uiVariant.heroVariant == HeroVariant.businessDashboard) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.heroGradient,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.accent.withValues(alpha: 0.26),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Text(
                          content.badgeText(locale),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: theme.badgeColor,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Espace entreprise',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 30,
                                  color: theme.heroForeground,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gerez vos obligations administratives, fiscales et sociales depuis un tableau de bord structure.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: theme.heroMutedForeground,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _HeroGlyph(theme: theme, profile: profile),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _EnterpriseMetric(
                    title: 'Registre',
                    subtitle: 'RNE, SARL',
                    icon: Icons.badge_rounded,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _EnterpriseMetric(
                    title: 'Fiscalite',
                    subtitle: 'TVA, declaration',
                    icon: Icons.calculate_rounded,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _EnterpriseMetric(
                    title: 'Social',
                    subtitle: 'CNSS, obligations',
                    icon: Icons.shield_rounded,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ContextualHeader(
      badge: content.badgeText(locale),
      title: content.titleText(locale),
      subtitle: content.subtitleText(locale),
      theme: theme,
      trailing: _HeroGlyph(theme: theme, profile: profile),
    );
  }
}

class _EnterpriseMetric extends StatelessWidget {
  const _EnterpriseMetric({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.theme,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ProfileThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.professionalAccent.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.professionalAccent),
          ),
          const SizedBox(width: 10),
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
                        color: theme.heroMutedForeground,
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
