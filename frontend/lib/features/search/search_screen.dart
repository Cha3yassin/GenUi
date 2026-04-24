import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/constants/route_paths.dart';
import '../../core/genui/genui_providers.dart';
import '../../core/genui/profile_config.dart';
import '../../core/genui/procedure_config.dart';
import '../../core/utils/async_value_widget.dart';
import '../../shared/models/procedure_summary_model.dart';
import '../../shared/widgets/adaptive_empty_state.dart';
import '../../shared/widgets/animated_reveal.dart';
import '../../shared/widgets/contextual_header.dart';
import '../../shared/widgets/procedure_card.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../../shared/widgets/sahil_chip_button.dart';
import '../../shared/widgets/sahil_search_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../core/locale/locale_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsValue = ref.watch(searchResultsProvider);
    final locale = ref.watch(localeProvider);
    final profile = ref.watch(effectiveProfileProvider);
    final content = getProfileContent(profile);
    final theme = getThemeByProfile(profile);
    final uiVariant = getProfileUiVariant(profile);
    final suggestions = getRecommendedProcedures(profile).take(5).toList();
    final quickFilters = getQuickFilters(profile, locale);

    return Scaffold(
      backgroundColor: theme.pageBackground,
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Container(
          color: theme.pageBackground,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedReveal(
                  child: profile == ProfileType.enterprise
                      ? _EnterpriseSearchHeader(theme: theme)
                      : ContextualHeader(
                          badge: content.badgeText(locale),
                          title: content.searchTitleText(locale),
                          subtitle: content.searchSubtitleText(locale),
                          theme: theme,
                        ),
                ),
                const SizedBox(height: 16),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 60),
                  child: ProfileSwitcher(locale: locale),
                ),
                const SizedBox(height: 20),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 120),
                  child: SahilSearchBar(
                    controller: _controller,
                    hintText: content.searchHintText(locale),
                    contextLabel: profileLabel(profile, locale),
                    accentColor: theme.accent,
                    variant:
                        uiVariant.searchVariant == SearchVariant.professional
                            ? SahilSearchBarVariant.professional
                            : SahilSearchBarVariant.soft,
                    onSubmitted: (value) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      ref.read(searchQueryProvider.notifier).setQuery(value);
                    },
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).setQuery(value);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 180),
                  child: SectionHeader(
                    title: content.searchSuggestionsTitleText(locale),
                    subtitle: content.searchSuggestionsSubtitleText(locale),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 220),
                  child: uiVariant.searchVariant == SearchVariant.professional
                      ? Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: quickFilters.map((filter) {
                            return _FilterChip(
                              label: filter.label,
                              icon: filter.icon,
                              queryValue: filter.query,
                              controller: _controller,
                              isProfessional: true,
                            );
                          }).toList(),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: suggestions.map((slug) {
                            return _SuggestionChip(
                              label: procedureLabel(slug, locale),
                              queryValue: procedureLabel(slug, locale),
                              controller: _controller,
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 26),
                SectionHeader(
                  title: profile == ProfileType.enterprise
                      ? 'Resultats entreprise'
                      : 'Results',
                ),
                const SizedBox(height: 12),
                AsyncValueWidget<List<ProcedureSummaryModel>>(
                  value: resultsValue,
                  data: (results) {
                    if (results.isEmpty) {
                      return AdaptiveEmptyState(
                        title: content.emptyTitleText(locale),
                        body: content.emptyBodyText(locale),
                      );
                    }

                    return Column(
                      children: results.asMap().entries.map((entry) {
                        final index = entry.key;
                        final procedure = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == results.length - 1 ? 0 : 12,
                          ),
                          child: AnimatedReveal(
                            delay: Duration(milliseconds: 40 * index),
                            child: ProcedureCard(
                              procedure: procedure,
                              profileType: profile,
                              highlightLabel: _highlightForProcedure(
                                procedure.slug,
                                profile,
                              ),
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                context
                                    .push(RoutePaths.procedure(procedure.slug));
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _highlightForProcedure(String slug, ProfileType profile) {
    final priority = getProcedureConfig(slug)?.priority(profile) ?? 0;
    return priority >= 85 ? 'Top match' : null;
  }
}

class _EnterpriseSearchHeader extends StatelessWidget {
  const _EnterpriseSearchHeader({required this.theme});

  final ProfileThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.heroGradient,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: theme.accent.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recherche entreprise',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accedez rapidement aux formalites de registre, fiscalite et CNSS avec une recherche orientee gestion.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.heroMutedForeground,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.professionalAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.business_center_rounded, color: theme.accent),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  const _SuggestionChip({
    required this.label,
    required this.queryValue,
    required this.controller,
  });

  final String label;
  final String queryValue;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SahilChipButton(
      label: label,
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        controller.text = queryValue;
        ref.read(searchQueryProvider.notifier).setQuery(queryValue);
      },
    );
  }
}

class _FilterChip extends ConsumerWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.queryValue,
    required this.controller,
    this.isProfessional = false,
  });

  final String label;
  final IconData icon;
  final String queryValue;
  final TextEditingController controller;
  final bool isProfessional;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isProfessional) {
      return InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          controller.text = queryValue;
          ref.read(searchQueryProvider.notifier).setQuery(queryValue);
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD7DEE8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFFD6A94A)),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF1E2A44),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SahilChipButton(
      label: label,
      icon: icon,
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        controller.text = queryValue;
        ref.read(searchQueryProvider.notifier).setQuery(queryValue);
      },
    );
  }
}
