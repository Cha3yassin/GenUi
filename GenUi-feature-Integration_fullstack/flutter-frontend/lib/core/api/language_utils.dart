class LanguageUtils {
  LanguageUtils._();

  static final RegExp _arabicText = RegExp(r'[\u0600-\u06FF]');

  static String preferredLanguageFor(String text) {
    return _arabicText.hasMatch(text) ? 'ar' : 'fr';
  }

  static bool isArabic(String text) => preferredLanguageFor(text) == 'ar';
}
