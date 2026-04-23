import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static String get backendBaseUrl {
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
