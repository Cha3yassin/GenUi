import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../shared/models/category_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import 'api_service.dart';
import 'app_config.dart';
import 'language_utils.dart';
import 'procedure_guide_adapter.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'ApiException: $message ($code)';
}

class HttpApiService implements ApiService {
  final http.Client _client = http.Client();

  Future<dynamic> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.apiV1}$path',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await _client.get(uri).timeout(AppConfig.requestTimeout);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }
      throw ApiException(
        decoded['message'] ?? 'Erreur serveur',
        decoded['code'],
      );
    } on TimeoutException {
      throw ApiException('Delai de connexion depasse.', 'TIMEOUT');
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.', 'NETWORK_ERROR');
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConfig.apiV1}$path');

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic> && decoded['type'] == 'error') {
          throw ApiException(
              decoded['message'] ?? 'Erreur IA', decoded['code']);
        }
        return decoded;
      }
      throw ApiException(
        decoded['message'] ?? 'Erreur serveur',
        decoded['code'],
      );
    } on TimeoutException {
      throw ApiException(
          'Le service IA met trop de temps a repondre.', 'TIMEOUT');
    } on SocketException {
      throw ApiException(
          'Impossible de connecter au serveur IA.', 'NETWORK_ERROR');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _get('/categories') as List;
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [
        CategoryModel.fromJson({
          'id': 'vehicles',
          'slug': 'vehicles',
          'title': 'Vehicules',
          'description': 'Carte grise, vente...',
          'icon': 'directions_car',
          'accentColor': 0xFFB45745,
        }),
        CategoryModel.fromJson({
          'id': 'civil_status',
          'slug': 'civil_status',
          'title': 'Etat Civil',
          'description': 'Passeport, CIN...',
          'icon': 'badge',
          'accentColor': 0xFF68775A,
        }),
        CategoryModel.fromJson({
          'id': 'business',
          'slug': 'business',
          'title': 'Entreprises',
          'description': 'Creation, statuts...',
          'icon': 'business_center',
          'accentColor': 0xFF6F625D,
        }),
        CategoryModel.fromJson({
          'id': 'taxation',
          'slug': 'taxation',
          'title': 'Fiscalite',
          'description': 'Taxes, impots...',
          'icon': 'receipt_percent',
          'accentColor': 0xFF843B31,
        }),
      ];
    }
  }

  @override
  Future<List<ProcedureSummaryModel>> searchProcedures(String query) async {
    if (query.trim().length < 2) return [];

    try {
      final data = await _get(
        '/procedures/search',
        queryParameters: {
          'q': query,
          'language': LanguageUtils.preferredLanguageFor(query),
        },
      );
      return (data as List)
          .map(
            (json) =>
                ProcedureSummaryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur inattendue lors de la recherche.');
    }
  }

  @override
  Future<List<ProcedureSummaryModel>> getProceduresByCategory(
    String categoryId,
  ) async {
    try {
      final data = await _get('/procedures/by-category/$categoryId');
      return (data as List)
          .map(
            (json) =>
                ProcedureSummaryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du chargement des procedures.');
    }
  }

  @override
  Future<ProcedureModel> getProcedureDetail(String slug) async {
    final message = slug.replaceAll('-', ' ');
    final language = LanguageUtils.preferredLanguageFor(message);

    try {
      // ── Step 1: POST the search request ──────────────────────────────────
      final uri = Uri.parse('${AppConfig.apiV1}/gen-ui/search');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': message, 'language': language}),
          )
          .timeout(AppConfig.requestTimeout);

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      // ── Step 2: Handle cache hit (200 with procedure_guide) ──────────────
      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic> && decoded['type'] == 'error') {
          throw ApiException(
              decoded['message'] ?? 'Erreur IA', decoded['code']);
        }
        return ProcedureGuideAdapter.fromJson(
          decoded as Map<String, dynamic>,
          slug: slug,
          language: language,
        );
      }

      // ── Step 3: Handle cache miss (202 with task_id) ─────────────────────
      if (response.statusCode == 202 &&
          decoded is Map<String, dynamic> &&
          decoded['task_id'] != null) {
        final taskId = decoded['task_id'] as String;
        return _pollForResult(taskId, slug, language);
      }

      // Unexpected status code
      throw ApiException(
        decoded is Map ? (decoded['message'] ?? 'Erreur serveur') : 'Erreur serveur',
        decoded is Map ? decoded['code'] : null,
      );
    } on TimeoutException {
      throw ApiException(
          'Le service IA met trop de temps a repondre.', 'TIMEOUT');
    } on SocketException {
      throw ApiException(
          'Impossible de connecter au serveur IA.', 'NETWORK_ERROR');
    }
  }

  /// Polls the task status endpoint until the task completes, fails, or times out.
  Future<ProcedureModel> _pollForResult(
    String taskId,
    String slug,
    String language,
  ) async {
    final deadline = DateTime.now().add(AppConfig.maxPollDuration);
    final statusUri =
        Uri.parse('${AppConfig.apiV1}/gen-ui/tasks/$taskId/status');

    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(AppConfig.pollInterval);

      try {
        final pollResponse =
            await _client.get(statusUri).timeout(AppConfig.requestTimeout);
        final pollData = jsonDecode(utf8.decode(pollResponse.bodyBytes));

        if (pollData is! Map<String, dynamic>) continue;

        final status = pollData['status'] as String?;

        if (status == 'complete' && pollData['result'] != null) {
          final result = pollData['result'] as Map<String, dynamic>;
          if (result['type'] == 'error') {
            throw ApiException(
                result['message'] ?? 'Erreur IA', result['code']);
          }
          return ProcedureGuideAdapter.fromJson(
            result,
            slug: slug,
            language: language,
          );
        }

        if (status == 'failed') {
          throw ApiException(
            pollData['error'] ?? 'La tache a echoue.',
            'TASK_FAILED',
          );
        }

        // status == 'processing' → continue polling
      } on ApiException {
        rethrow;
      } catch (_) {
        // Network hiccup during poll — retry on next interval
      }
    }

    throw ApiException(
      'Le delai d\'attente est depasse. Veuillez reessayer.',
      'POLL_TIMEOUT',
    );
  }

  @override
  Future<List<OfficeModel>> getNearbyOffices({
    String? stepId,
    double? lat,
    double? lng,
  }) async {
    try {
      final query = <String, String>{};
      if (stepId != null && stepId.trim().isNotEmpty) {
        query['stepId'] = stepId;
      }
      if (lat != null && lng != null) {
        query['lat'] = lat.toString();
        query['lng'] = lng.toString();
      }

      final data = await _get('/offices/nearby', queryParameters: query);
      return (data as List)
          .map((json) => OfficeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du chargement des localisations.');
    }
  }
}
