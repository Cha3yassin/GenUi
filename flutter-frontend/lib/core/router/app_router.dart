import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/offices/office_locator_screen.dart';
import '../../features/procedures/category_procedures_screen.dart';
import '../../features/procedures/procedure_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../constants/route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/procedures/:slug',
        builder: (context, state) => ProcedureDetailScreen(
          slug: state.pathParameters['slug'] ?? 'buy-used-car',
        ),
      ),
      GoRoute(
        path: '/categories/:categoryId/procedures',
        builder: (context, state) => CategoryProceduresScreen(
          categoryId: state.pathParameters['categoryId'] ?? 'vehicles',
        ),
      ),
      GoRoute(
        path: RoutePaths.offices,
        builder: (context, state) =>
            OfficeLocatorScreen(stepId: state.uri.queryParameters['stepId']),
      ),
    ],
  );
});
