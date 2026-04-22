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
import 'procedure_guide_adapter.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  ApiException(this.message, [this.code]);
  
  @override
  String toString() => 'ApiException: $message ($code)';
}

class HttpApiService implements ApiService {
  final http.Client _client = http.Client();

  Future<dynamic> _get(String path, {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse('${AppConfig.apiV1}$path').replace(queryParameters: queryParameters);
    try {
      final response = await _client.get(uri).timeout(AppConfig.requestTimeout);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw ApiException(decoded['message'] ?? 'Erreur Serveur', decoded['code']);
      }
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé. Vérifiez votre connexion.', 'TIMEOUT');
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur. Vérifiez votre connexion.', 'NETWORK_ERROR');
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConfig.apiV1}$path');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(AppConfig.requestTimeout);
      
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // FastAPI might return a 200 OK with an ErrorResponse body (e.g. from GenUI fallback)
        if (decoded is Map<String, dynamic> && decoded['type'] == 'error') {
          throw ApiException(decoded['message'] ?? 'Erreur IA', decoded['code']);
        }
        return decoded;
      } else {
        throw ApiException(decoded['message'] ?? 'Erreur Serveur', decoded['code']);
      }
    } on TimeoutException {
      throw ApiException('Le serveur IA met trop de temps à répondre.', 'TIMEOUT');
    } on SocketException {
      throw ApiException('Impossible de connecter au serveur AI.', 'NETWORK_ERROR');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    // Currently, backend does not have a public /categories GET endpoint implemented in the provided code snippets (though it is registered). 
    // Fallback to static if backend isn't ready. This app uses hardcoded in mock so let's mock categories for now if you prefer or if we know it fails we can catch.
    try {
      final data = await _get('/categories') as List;
      return data.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (_) {
      // Return predefined categories matching the mock but with IDs matching Backend Slugs
      return [
        CategoryModel.fromJson({'id': 'vehicles', 'slug': 'vehicles', 'title': 'Véhicules', 'description': 'Carte grise, vente...', 'icon': 'directions_car', 'accentColor': 0xFFB45745}),
        CategoryModel.fromJson({'id': 'civil_status', 'slug': 'civil_status', 'title': 'État Civil', 'description': 'Passeport, CIN...', 'icon': 'badge', 'accentColor': 0xFF68775A}),
        CategoryModel.fromJson({'id': 'business', 'slug': 'business', 'title': 'Entreprises', 'description': 'Création, statuts...', 'icon': 'business_center', 'accentColor': 0xFF6F625D}),
        CategoryModel.fromJson({'id': 'taxation', 'slug': 'taxation', 'title': 'Fiscalité', 'description': 'Taxes, impôts...', 'icon': 'receipt_percent', 'accentColor': 0xFF843B31}),
      ];
    }
  }

  @override
  Future<List<ProcedureSummaryModel>> searchProcedures(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final data = await _get('/procedures/search', queryParameters: {'q': query});
      return (data as List).map((json) => ProcedureSummaryModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is ApiException) throw e;
      throw ApiException('Erreur inattendue lors de la recherche.');
    }
  }

  @override
  Future<List<ProcedureSummaryModel>> getProceduresByCategory(String categoryId) async {
    try {
      final data = await _get('/procedures/by-category/$categoryId');
      return (data as List).map((json) => ProcedureSummaryModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is ApiException) throw e;
      throw ApiException('Erreur lors du chargement des procédures.');
    }
  }

  @override
  Future<ProcedureModel> getProcedureDetail(String slug) async {
    // We use GenUI search endpoint to generate procedure detail block on the fly!
    // The slug is often effectively a search query like 'buy-used-car' or actual query.
    final message = slug.replaceAll('-', ' ');
    try {
      final responseData = await _post('/gen-ui/search', {
        'message': message,
        'language': AppConfig.defaultLanguage,
      });

      // Pass the response to the adapter
      return ProcedureGuideAdapter.fromJson(responseData as Map<String, dynamic>, slug: slug);
    } catch (e) {
      if (e is ApiException) throw e;
      throw ApiException('Erreur inattendue. Veuillez réessayer.');
    }
  }

  @override
  Future<List<OfficeModel>> getNearbyOffices({String? stepId, double? lat, double? lng}) async {
    // Keeping mock response format for offices until backend `/offices` endpoint is built
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      OfficeModel(id: '1', name: 'ATTT - Centre', type: 'Véhicules', address: 'Tunis', distance: '1.2 km', workingHours: '08:00 - 14:00', isOpen: true),
    ];
  }
}
