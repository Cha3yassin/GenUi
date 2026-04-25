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
import '../../shared/widgets/floating_widget.dart';
import '../../shared/widgets/press_scale.dart';
import '../../shared/widgets/sahil_chip_button.dart';
import '../../shared/widgets/sahil_search_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stagger_list.dart';
import '../history/history_drawer.dart';

// ── Local role toggle provider ────────────────────────────────────────────────
final _activeTabProvider = StateProvider<int>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'enterprise' ? 1 : 0;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
    final isRtl = locale == 'ar';
    final isAuthenticated = authState.isAuthenticated;
    final lockedTab =
        isAuthenticated ? (authState.user?.role == 'enterprise' ? 1 : 0) : null;

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
                _HeroSection(locale: locale),
                const SizedBox(height: 22),
                if (!isAuthenticated) const _RoleToggle(),
                const SizedBox(height: 24),
                _TabContent(lockedTab: lockedTab),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role toggle ───────────────────────────────────────────────────────────────

class _RoleToggle extends ConsumerWidget {
  const _RoleToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(_activeTabProvider);
    final locale = ref.watch(localeProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          _ToggleSegment(
            label: AppStrings.get('tab_individual', locale),
            isActive: activeTab == 0,
            onTap: () => ref.read(_activeTabProvider.notifier).state = 0,
          ),
          const SizedBox(width: 4),
          _ToggleSegment(
            label: AppStrings.get('tab_enterprise', locale),
            isActive: activeTab == 1,
            onTap: () => ref.read(_activeTabProvider.notifier).state = 1,
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment(
      {required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.darkNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppTheme.mutedInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab content switcher ──────────────────────────────────────────────────────

class _TabContent extends ConsumerWidget {
  const _TabContent({this.lockedTab});

  final int? lockedTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = lockedTab ?? ref.watch(_activeTabProvider);
    final locale = ref.watch(localeProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        // Horizontal drift in the direction of the tab
        final isEnterprise = (child.key == const ValueKey('enterprise'));
        final drift = Tween<Offset>(
          begin: Offset(isEnterprise ? 0.05 : -0.05, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: drift, child: child),
        );
      },
      child: activeTab == 0
          ? _IndividualTab(key: const ValueKey('individual'), locale: locale)
          : _EnterpriseTab(key: const ValueKey('enterprise'), locale: locale),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INDIVIDUAL TAB — unchanged from before
// ══════════════════════════════════════════════════════════════════════════════

class _IndividualTab extends ConsumerWidget {
  const _IndividualTab({super.key, required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesValue = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SahilSearchBar(
          hintText: AppStrings.get('search_hint', locale),
          readOnly: true,
          onTap: () => context.push(RoutePaths.search),
          placeholderExamples: [
            AppStrings.get('search_example_1', locale),
            AppStrings.get('search_example_2', locale),
            AppStrings.get('search_example_3', locale),
            AppStrings.get('search_example_4', locale),
          ],
        ),
        const SizedBox(height: 32),
        _PopularSection(locale: locale, role: 'individual'),
        const SizedBox(height: 32),
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
        _TrustCard(locale: locale),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ENTERPRISE TAB — new dedicated layout
// ══════════════════════════════════════════════════════════════════════════════

class _EnterpriseTab extends StatefulWidget {
  const _EnterpriseTab({super.key, required this.locale});
  final String locale;

  @override
  State<_EnterpriseTab> createState() => _EnterpriseTabState();
}

class _EnterpriseTabState extends State<_EnterpriseTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final delay = (index * 80) / 800;
    final begin = delay.clamp(0.0, 0.85);
    final end = (begin + 0.4).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position:
            Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.locale;
    int i = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero card
        _stagger(i++, _EnterpriseHeroCard(locale: l)),
        const SizedBox(height: 18),

        // 2. Search bar
        _stagger(
            i++,
            SahilSearchBar(
              hintText: AppStrings.get('search_enterprise_hint', l),
              readOnly: true,
              onTap: () => context.push(RoutePaths.search),
            )),
        const SizedBox(height: 24),

        // 3. Filter chips
        _stagger(i++, _EnterpriseFilterChips(locale: l)),
        const SizedBox(height: 28),

        // 4. Priority actions
        _stagger(
            i++,
            SectionHeader(
              title: AppStrings.get('priority_actions', l),
              subtitle: AppStrings.get('priority_actions_subtitle', l),
            )),
        const SizedBox(height: 16),

        _stagger(
            i++,
            _ActionPriorityCard(
              icon: Icons.business_center_rounded,
              title: AppStrings.get('action_create_company', l),
              subtitle: AppStrings.get('action_create_company_subtitle', l),
              accentColor: AppTheme.actionYellow,
              items: [
                (
                  AppStrings.get('sub_sarl', l),
                  'register-company-sarl-tunisia'
                ),
                (AppStrings.get('sub_rne', l), 'rne-registration-tunisia'),
                (AppStrings.get('sub_patente', l), 'patente-tunisia'),
              ],
              consultLabel: AppStrings.get('consult_all', l),
            )),
        const SizedBox(height: 12),

        _stagger(
            i++,
            _ActionPriorityCard(
              icon: Icons.receipt_long_rounded,
              title: AppStrings.get('action_fiscal', l),
              subtitle: AppStrings.get('action_fiscal_subtitle', l),
              accentColor: AppTheme.actionBlue,
              items: [
                (AppStrings.get('sub_tva', l), 'tva-tunisia'),
                (
                  AppStrings.get('sub_declaration', l),
                  'tax-declaration-tunisia'
                ),
                (AppStrings.get('sub_quitus', l), 'quitus-fiscal-tunisia'),
              ],
              consultLabel: AppStrings.get('consult_all', l),
            )),
        const SizedBox(height: 12),

        _stagger(
            i++,
            _ActionPriorityCard(
              icon: Icons.shield_rounded,
              title: AppStrings.get('action_social', l),
              subtitle: AppStrings.get('action_social_subtitle', l),
              accentColor: AppTheme.actionGreen,
              items: [
                (AppStrings.get('sub_cnss', l), 'cnss-tunisia'),
                (AppStrings.get('sub_cnam', l), 'cnam-tunisia'),
                (AppStrings.get('sub_retraite', l), 'retraite-tunisia'),
              ],
              consultLabel: AppStrings.get('consult_all', l),
            )),
      ],
    );
  }
}

// ── Enterprise hero card ──────────────────────────────────────────────────────

class _EnterpriseHeroCard extends StatefulWidget {
  const _EnterpriseHeroCard({required this.locale});
  final String locale;

  @override
  State<_EnterpriseHeroCard> createState() => _EnterpriseHeroCardState();
}

class _EnterpriseHeroCardState extends State<_EnterpriseHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientCtrl;

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientCtrl,
      builder: (context, child) {
        final t = _gradientCtrl.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppTheme.darkNavy, const Color(0xFF243B55), t)!,
                Color.lerp(const Color(0xFF141E30), AppTheme.darkNavy, t)!,
              ],
            ),
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('espace_entreprise', widget.locale),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.get('espace_entreprise_subtitle', widget.locale),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FloatingWidget(
            amplitude: 3,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.actionYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.business_center_rounded,
                  color: AppTheme.actionYellow, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Enterprise filter chips ───────────────────────────────────────────────────

class _EnterpriseFilterChips extends StatelessWidget {
  const _EnterpriseFilterChips({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    final filters = [
      (
        AppStrings.get('filter_fiscalite', locale),
        Icons.account_balance_rounded,
        AppTheme.actionYellow
      ),
      (
        AppStrings.get('filter_creation', locale),
        Icons.add_business_rounded,
        AppTheme.actionOrange
      ),
      (
        AppStrings.get('filter_social', locale),
        Icons.people_rounded,
        AppTheme.actionGreen
      ),
      (
        AppStrings.get('filter_registre', locale),
        Icons.folder_rounded,
        AppTheme.actionBlue
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: f.$3.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: f.$3.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.$2, size: 18, color: f.$3),
                  const SizedBox(width: 8),
                  Text(f.$1,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: f.$3,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Action priority card ──────────────────────────────────────────────────────

class _ActionPriorityCard extends StatelessWidget {
  const _ActionPriorityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.items,
    required this.consultLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<(String label, String slug)> items;
  final String consultLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left colored border
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: icon + title + subtitle
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: accentColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.ink,
                                  )),
                              const SizedBox(height: 3),
                              Text(subtitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.mutedInk,
                                    height: 1.3,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Sub-items
                    ...items.map((item) => _SubItem(
                          label: item.$1,
                          slug: item.$2,
                          color: accentColor,
                        )),
                    // Consult link
                    const SizedBox(height: 8),
                    Text(consultLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubItem extends StatelessWidget {
  const _SubItem(
      {required this.label, required this.slug, required this.color});
  final String label;
  final String slug;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RoutePaths.procedure(slug)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.ink,
                    ))),
            Icon(Icons.north_east_rounded,
                size: 16, color: AppTheme.mutedInk.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS (kept from original)
// ══════════════════════════════════════════════════════════════════════════════

class _PopularSection extends StatelessWidget {
  const _PopularSection({required this.locale, required this.role});
  final String locale;
  final String? role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.get('popular_this_week', locale),
          subtitle: AppStrings.get('popular_subtitle', locale),
        ),
        const SizedBox(height: 14),
        Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _individualChips(context, locale)),
      ],
    );
  }

  List<Widget> _individualChips(BuildContext context, String locale) => [
        SahilChipButton(
            label: AppStrings.get('buy_car', locale),
            icon: Icons.directions_car_rounded,
            onPressed: () =>
                context.push(RoutePaths.procedure('buy-used-car'))),
        SahilChipButton(
            label: AppStrings.get('passport_renewal', locale),
            icon: Icons.badge_rounded,
            onPressed: () =>
                context.push(RoutePaths.procedure('passport-renewal'))),
        SahilChipButton(
            label: AppStrings.get('marriage_certificate', locale),
            icon: Icons.favorite_rounded,
            onPressed: () =>
                context.push(RoutePaths.procedure('marriage-certificate'))),
        SahilChipButton(
            label: AppStrings.get('national_id_card', locale),
            icon: Icons.credit_card_rounded,
            onPressed: () =>
                context.push(RoutePaths.procedure('national-id-card-cin'))),
      ];
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
                      padding: EdgeInsets.zero),
                )),
        const Spacer(),
        _LanguageToggle(locale: locale),
        const SizedBox(width: 10),
        if (authState.isAuthenticated)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoleBadge(
                roleLabel: AppStrings.get(authState.user!.role, locale),
              ),
              const SizedBox(width: 8),
              _UserAvatar(email: authState.user!.email),
            ],
          )
        else
          Container(
            height: 36,
            decoration: BoxDecoration(
                color: AppTheme.terracotta,
                borderRadius: BorderRadius.circular(12)),
            child: TextButton(
              onPressed: () => context.push(RoutePaths.login),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700)),
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
        email.isNotEmpty ? email[0].toUpperCase() : '?',
        style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.terracotta),
      )),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.roleLabel});

  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.darkNavy.withOpacity(0.15)),
      ),
      child: Text(
        roleLabel,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.darkNavy,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.get('app_name', locale),
            style: GoogleFonts.playfairDisplay(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
                letterSpacing: -0.6)),
        const SizedBox(height: 6),
        Text(AppStrings.get('app_tagline', locale),
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppTheme.mutedInk, height: 1.5)),
      ],
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
          border: Border.all(color: AppTheme.borderLight)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _LangChip(
            label: 'AR',
            isActive: locale == 'ar',
            onTap: () => ref.read(localeProvider.notifier).setLocale('ar')),
        _LangChip(
            label: 'EN',
            isActive: locale == 'en',
            onTap: () => ref.read(localeProvider.notifier).setLocale('en')),
        _LangChip(
            label: 'FR',
            isActive: locale == 'fr',
            onTap: () => ref.read(localeProvider.notifier).setLocale('fr')),
      ]),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip(
      {required this.label, required this.isActive, required this.onTap});
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
            borderRadius: BorderRadius.circular(9)),
        child: Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isActive
                    ? Colors.white
                    : AppTheme.mutedInk.withOpacity(0.5),
                letterSpacing: 0.5)),
      ),
    );
  }
}

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
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return CategoryCard(
            category: cat,
            locale: locale,
            onTap: () => context.push(RoutePaths.categoryProcedures(cat.id)),
            onProcedureTap: (slug) => context.push(RoutePaths.procedure(slug)));
      },
    );
  }
}

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight)),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppTheme.olive.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.fact_check_rounded,
                color: AppTheme.olive, size: 22)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.get('trust_title', locale),
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(AppStrings.get('trust_body', locale),
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
        ])),
      ]),
    );
  }
}
