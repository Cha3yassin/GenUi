/// lib/core/api/app_config.dart
///
/// Centralised backend configuration.
/// Change [backendBaseUrl] to point to your running FastAPI server.
///
/// Development targets:
///   • Android emulator  → http://10.0.2.2:8000
///   • iOS simulator     → http://localhost:8000
///   • Physical device   → http://<your-machine-LAN-ip>:8000
///   • Production        → https://your-domain.com

class AppConfig {
  AppConfig._();

  /// Base URL of the FastAPI backend. No trailing slash.
  static const String backendBaseUrl = 'http://127.0.0.1:8000';

  /// API version prefix
  static const String apiV1 = '$backendBaseUrl/api/v1';

  /// Default language sent to the backend
  static const String defaultLanguage = 'fr';

  /// HTTP request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
