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
      final responseData = await _post('/gen-ui/search', {
        'message': message,
        'language': language,
      });

      return ProcedureGuideAdapter.fromJson(
        responseData as Map<String, dynamic>,
        slug: slug,
        language: language,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur inattendue. Veuillez reessayer.');
    }
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
