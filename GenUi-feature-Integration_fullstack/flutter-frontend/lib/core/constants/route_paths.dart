class RoutePaths {
  const RoutePaths._();

  static const splash = '/';
  static const home = '/home';
  static const search = '/search';
  static const offices = '/offices';

  static String procedure(String slug) {
    return '/${Uri(pathSegments: ['procedures', slug])}';
  }

  static String categoryProcedures(String categoryId) {
    return '/${Uri(pathSegments: [
          'categories',
          categoryId,
          'procedures',
        ])}';
  }
}
