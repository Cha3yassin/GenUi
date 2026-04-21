import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/constants/route_paths.dart';
import '../../core/utils/async_value_widget.dart';
import '../../shared/models/procedure_summary_model.dart';
import '../../shared/widgets/procedure_card.dart';
import '../../shared/widgets/sahil_chip_button.dart';
import '../../shared/widgets/sahil_search_bar.dart';
import '../../shared/widgets/section_header.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SahilSearchBar(
                controller: _controller,
                hintText: 'Try: buy a used car, carte grise, passeport',
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).setQuery(value);
                },
              ),
              const SizedBox(height: 20),
              const SectionHeader(
                title: 'Suggestions',
                subtitle: 'Start with a common Tunisian procedure.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SuggestionChip(
                    label: 'buy a used car',
                    controller: _controller,
                  ),
                  _SuggestionChip(
                    label: 'carte grise',
                    controller: _controller,
                  ),
                  _SuggestionChip(label: 'passeport', controller: _controller),
                  _SuggestionChip(label: 'entreprise', controller: _controller),
                ],
              ),
              const SizedBox(height: 26),
              const SectionHeader(title: 'Results'),
              const SizedBox(height: 12),
              AsyncValueWidget<List<ProcedureSummaryModel>>(
                value: resultsValue,
                data: (results) {
                  if (results.isEmpty) {
                    return const _EmptyResults();
                  }

                  return Column(
                    children: [
                      for (final procedure in results) ...[
                        ProcedureCard(
                          procedure: procedure,
                          onTap: () => context.push(
                            RoutePaths.procedure(procedure.slug),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
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
        controller.text = label;
        ref.read(searchQueryProvider.notifier).setQuery(label);
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Text(
          'No matching procedure yet. Try a broader keyword or browse categories.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
