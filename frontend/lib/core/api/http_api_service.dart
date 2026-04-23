import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../shared/models/category_model.dart';
import '../../shared/models/history_summary_model.dart';
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

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<dynamic> _get(
    String path, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.apiV1}$path',
    ).replace(queryParameters: queryParameters);

    try {
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response =
          await _client.get(uri, headers: headers).timeout(AppConfig.requestTimeout);
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

  // ── Categories ─────────────────────────────────────────────────────────────

  @override
  Future<List<CategoryModel>> getCategories({String? role}) async {
    try {
      final query = <String, String>{};
      if (role != null) query['role'] = role;
      final data = await _get('/categories', queryParameters: query.isNotEmpty ? query : null) as List;
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

  // ── Search ─────────────────────────────────────────────────────────────────

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

  // ── GenUI with polling ─────────────────────────────────────────────────────

  @override
  Future<ProcedureModel> getProcedureDetail(String slug, {String? role}) async {
    final message = slug.replaceAll('-', ' ');
    final language = LanguageUtils.preferredLanguageFor(message);

    try {
      final uri = Uri.parse('${AppConfig.apiV1}/gen-ui/search');
      final body = <String, dynamic>{
        'message': message,
        'language': language,
      };
      if (role != null) body['role'] = role;

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

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

      if (response.statusCode == 202 &&
          decoded is Map<String, dynamic> &&
          decoded['task_id'] != null) {
        final taskId = decoded['task_id'] as String;
        return _pollForResult(taskId, slug, language);
      }

      throw ApiException(
        decoded is Map
            ? (decoded['message'] ?? 'Erreur serveur')
            : 'Erreur serveur',
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
      } on ApiException {
        rethrow;
      } catch (_) {}
    }

    throw ApiException(
      'Le delai d\'attente est depasse. Veuillez reessayer.',
      'POLL_TIMEOUT',
    );
  }

  // ── Offices ────────────────────────────────────────────────────────────────

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

  // ── History (authenticated) ────────────────────────────────────────────────

  @override
  Future<List<HistorySummary>> getHistorySummaries(String token) async {
    try {
      final data = await _get('/history/me/summaries', token: token);
      final items = (data['items'] as List?) ?? [];
      return items
          .map((json) => HistorySummary.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du chargement de l\'historique.');
    }
  }

  @override
  Future<Map<String, dynamic>> getHistoryDetail(
      String token, String historyId) async {
    try {
      final data = await _get('/history/me/$historyId', token: token);
      return data as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du chargement du détail.');
    }
  }
}
