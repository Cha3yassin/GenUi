import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
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
        path: RoutePaths.login,
        pageBuilder: (context, state) => _springPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.home,
        pageBuilder: (context, state) => _springPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.search,
        pageBuilder: (context, state) => _springPage(
          key: state.pageKey,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/procedures/:slug',
        pageBuilder: (context, state) => _springPage(
          key: state.pageKey,
          child: ProcedureDetailScreen(
            slug: _safePathParameter(state.pathParameters['slug'], 'buy-used-car'),
          ),
        ),
      ),
      GoRoute(
        path: '/categories/:categoryId/procedures',
        pageBuilder: (context, state) => _springPage(
          key: state.pageKey,
          child: CategoryProceduresScreen(
            categoryId: state.pathParameters['categoryId'] ?? 'vehicles',
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.offices,
        pageBuilder: (context, state) => _springPage(
          key: state.pageKey,
          child: OfficeLocatorScreen(stepId: state.uri.queryParameters['stepId']),
        ),
      ),
      GoRoute(
        path: '/history/:historyId',
        pageBuilder: (context, state) {
          final historyId = state.pathParameters['historyId'] ?? '';
          return _springPage(
            key: state.pageKey,
            child: ProcedureDetailScreen(
              slug: 'history-$historyId',
              historyId: historyId,
            ),
          );
        },
      ),
    ],
  );
});

/// Spring slide-up page transition.
/// New page slides up from bottom with spring curve.
/// Previous page scales down to 0.95 and dims.
CustomTransitionPage<void> _springPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Entering page: slide up + fade in
      final slideIn = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      );

      // Exiting page: scale down + dim
      final scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
        ),
      );

      final dimOut = Tween<double>(begin: 1.0, end: 0.6).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOut,
        ),
      );

      return ScaleTransition(
        scale: scaleOut,
        child: FadeTransition(
          opacity: dimOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(
              opacity: fadeIn,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

String _safePathParameter(String? value, String fallback) {
  final raw = value ?? fallback;
  if (!raw.contains('%')) return raw;
  try {
    return Uri.decodeComponent(raw);
  } on FormatException {
    return raw;
  } on ArgumentError {
    return raw;
  }
}
