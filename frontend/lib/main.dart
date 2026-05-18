import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

import 'core/auth/auth_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/locale/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — requires firebase_options.dart from flutterfire configure
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e — auth features will be unavailable');
  }

  runApp(const ProviderScope(child: FbureaucracyApp()));
}

class FbureaucracyApp extends ConsumerStatefulWidget {
  const FbureaucracyApp({super.key});

  @override
  ConsumerState<FbureaucracyApp> createState() => _FbureaucracyAppState();
}

class _FbureaucracyAppState extends ConsumerState<FbureaucracyApp> {
  @override
  void initState() {
    super.initState();
    // Restore persisted locale and auth session on app start
    Future.microtask(() {
      ref.read(localeProvider.notifier).load();
      ref.read(authProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      locale: Locale(locale),
      supportedLocales: AppConstants.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection:
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
