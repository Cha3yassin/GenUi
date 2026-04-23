import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Current locale code: 'fr', 'en', or 'ar'.
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('fr');

  static const _key = 'app_locale';

  /// Load persisted locale from SharedPreferences.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null && ['fr', 'en', 'ar'].contains(saved)) {
        state = saved;
      }
    } catch (_) {}
  }

  /// Change locale and persist.
  Future<void> setLocale(String locale) async {
    if (!['fr', 'en', 'ar'].contains(locale)) return;
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale);
    } catch (_) {}
  }
}
