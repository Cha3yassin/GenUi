import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Backend base URL.
  ///
  /// - **Flutter Web (Docker / production):** Uses same origin (empty string)
  ///   because Nginx reverse-proxies `/api/*` to the backend container.
  /// - **Flutter Web (local dev):** `http://127.0.0.1:8000`
  /// - **Android emulator:** `http://10.0.2.2:8000`
  /// - **Other native:** `http://127.0.0.1:8000`
  ///
  /// Set the compile-time flag `--dart-define=DOCKER=true` when building
  /// the Docker image to activate the "same origin" mode.
  static const bool _isDocker = bool.fromEnvironment('DOCKER', defaultValue: false);

  static String get backendBaseUrl {
    if (kIsWeb && _isDocker) {
      // Nginx on the same origin proxies /api/* to the backend
      return '';
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String get apiV1 => '$backendBaseUrl/api/v1';

  static const String defaultLanguage = 'fr';

  /// Timeout for individual HTTP requests (GET/POST).
  static const Duration requestTimeout = Duration(seconds: 30);

  /// How often to poll for background task completion.
  static const Duration pollInterval = Duration(seconds: 2);

  /// Maximum time to keep polling before giving up.
  static const Duration maxPollDuration = Duration(seconds: 120);
}
