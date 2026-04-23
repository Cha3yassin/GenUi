import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/history_summary_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import '../auth/auth_provider.dart';
import 'api_service.dart';
import 'http_api_service.dart';
import 'procedure_guide_adapter.dart';

/// Provide the REAL API service
final apiServiceProvider = Provider<ApiService>((ref) => HttpApiService());

/// Categories — filtered by user role if authenticated.
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  final role = ref.watch(userRoleProvider);
  return ref.watch(apiServiceProvider).getCategories(role: role);
});

/// Procedure detail — passes user role for context-aware generation.
final procedureDetailProvider = FutureProvider.family<ProcedureModel, String>((
  ref,
  slug,
) {
  final role = ref.watch(userRoleProvider);
  return ref.watch(apiServiceProvider).getProcedureDetail(slug, role: role);
});

final categoryProceduresProvider =
    FutureProvider.family<List<ProcedureSummaryModel>, String>((
  ref,
  categoryId,
) {
  return ref.watch(apiServiceProvider).getProceduresByCategory(categoryId);
});

typedef NearbyOfficesQuery = ({String? stepId, double? lat, double? lng});

final nearbyOfficesProvider =
    FutureProvider.family<List<OfficeModel>, NearbyOfficesQuery>(
  (ref, query) {
    return ref.watch(apiServiceProvider).getNearbyOffices(
          stepId: query.stepId,
          lat: query.lat,
          lng: query.lng,
        );
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

/// History summaries for the drawer (requires auth).
final historySummariesProvider = FutureProvider<List<HistorySummary>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return [];

  final token = authState.user!.firebaseToken;
  return ref.watch(apiServiceProvider).getHistorySummaries(token);
});

/// History detail — fetches full JSON for a past procedure, renders instantly.
final historyDetailProvider =
    FutureProvider.family<ProcedureModel, String>((ref, historyId) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) {
    throw Exception('Not authenticated');
  }

  final token = authState.user!.firebaseToken;
  final data = await ref.watch(apiServiceProvider).getHistoryDetail(token, historyId);
  final aiResponse = data['ai_response'] as Map<String, dynamic>;

  return ProcedureGuideAdapter.fromJson(
    aiResponse,
    slug: 'history-$historyId',
    language: 'fr',
  );
});
