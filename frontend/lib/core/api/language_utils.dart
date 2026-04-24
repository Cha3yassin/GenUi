class LanguageUtils {
  LanguageUtils._();

  static final RegExp _arabicText = RegExp(r'[\u0600-\u06FF]');

  /// Detect language from text content. Returns 'ar', 'en', or 'fr'.
  static String preferredLanguageFor(String text) {
    if (_arabicText.hasMatch(text)) return 'ar';
    // Simple heuristic: if it contains common English words, use English
    final lower = text.toLowerCase();
    if (RegExp(r'\b(how|what|where|when|can|the|my|for|to)\b').hasMatch(lower)) {
      return 'en';
    }
    return 'fr';
  }

  static bool isArabic(String text) => preferredLanguageFor(text) == 'ar';
}
