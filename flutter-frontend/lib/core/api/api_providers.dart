import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import 'api_service.dart';
import 'http_api_service.dart';

/// Provide the REAL API service instead of the Mock
final apiServiceProvider = Provider<ApiService>((ref) => HttpApiService());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(apiServiceProvider).getCategories();
});

final procedureDetailProvider = FutureProvider.family<ProcedureModel, String>((
  ref,
  slug,
) {
  return ref.watch(apiServiceProvider).getProcedureDetail(slug);
});

final categoryProceduresProvider =
    FutureProvider.family<List<ProcedureSummaryModel>, String>((
      ref,
      categoryId,
    ) {
      return ref.watch(apiServiceProvider).getProceduresByCategory(categoryId);
    });

final nearbyOfficesProvider = FutureProvider.family<List<OfficeModel>, String?>(
  (ref, stepId) {
    return ref.watch(apiServiceProvider).getNearbyOffices(stepId: stepId);
  },
);

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }
}

/// Debounced search results provider
final searchResultsProvider = FutureProvider<List<ProcedureSummaryModel>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  
  if (query.trim().length < 2) {
    return [];
  }

  // Debounce: Cancel the request if the user types another letter within 400ms
  var isCancelled = false;
  ref.onDispose(() {
    isCancelled = true;
  });

  await Future<void>.delayed(const Duration(milliseconds: 400));
  
  if (isCancelled) {
    throw Exception('Search cancelled due to debounce');
  }

  return ref.watch(apiServiceProvider).searchProcedures(query);
});

