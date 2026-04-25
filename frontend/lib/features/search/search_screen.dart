import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/constants/route_paths.dart';
import '../../core/locale/app_strings.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/async_value_widget.dart';
import '../../shared/models/procedure_summary_model.dart';
import '../../shared/widgets/floating_widget.dart';
import '../../shared/widgets/press_scale.dart';
import '../../shared/widgets/procedure_card.dart';
import '../../shared/widgets/sahil_chip_button.dart';
import '../../shared/widgets/sahil_search_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stagger_list.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get('search', locale),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: StaggeredColumn(
            children: [
              SahilSearchBar(
                controller: _controller,
                hintText: AppStrings.get('search_try', locale),
                onSubmitted: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  ref.read(searchQueryProvider.notifier).setQuery(value);
                },
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: AppStrings.get('suggestions', locale),
                subtitle: AppStrings.get('suggestions_subtitle', locale),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SuggestionChip(label: AppStrings.get('chip_buy_car', locale), controller: _controller),
                  _SuggestionChip(label: AppStrings.get('chip_carte_grise', locale), controller: _controller),
                  _SuggestionChip(label: AppStrings.get('chip_passport', locale), controller: _controller),
                  _SuggestionChip(label: AppStrings.get('chip_enterprise', locale), controller: _controller),
                ],
              ),
              const SizedBox(height: 26),
              SectionHeader(title: AppStrings.get('results', locale)),
              const SizedBox(height: 12),
              AsyncValueWidget<List<ProcedureSummaryModel>>(
                value: resultsValue,
                data: (results) {
                  if (results.isEmpty) return _EmptyResults(locale: locale);
                  return _CascadingResults(results: results, locale: locale);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Results cascade in with 60ms stagger.
class _CascadingResults extends StatefulWidget {
  const _CascadingResults({required this.results, required this.locale});
  final List<ProcedureSummaryModel> results;
  final String locale;

  @override
  State<_CascadingResults> createState() => _CascadingResultsState();
}

class _CascadingResultsState extends State<_CascadingResults>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.results.length * 60),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = 300 + widget.results.length * 60;

    return Column(
      children: [
        for (int i = 0; i < widget.results.length; i++) ...[
          _cascadeItem(i, totalMs, PressScale(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              context.push(RoutePaths.procedure(widget.results[i].slug));
            },
            child: ProcedureCard(
              procedure: widget.results[i],
              locale: widget.locale,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.push(RoutePaths.procedure(widget.results[i].slug));
              },
            ),
          )),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _cascadeItem(int index, int totalMs, Widget child) {
    final delay = (index * 60) / totalMs;
    final begin = delay.clamp(0.0, 0.85);
    final end = (begin + 0.4).clamp(0.0, 1.0);

    final anim = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(anim),
        child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(anim), child: child),
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  const _SuggestionChip({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SahilChipButton(
      label: label,
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        controller.text = label;
        ref.read(searchQueryProvider.notifier).setQuery(label);
      },
    );
  }
}

/// Empty results with floating icon.
class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            FloatingWidget(
              child: Icon(Icons.search_off_rounded,
                  size: 40, color: AppTheme.mutedInk.withOpacity(0.3)),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.get('no_results', locale),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
