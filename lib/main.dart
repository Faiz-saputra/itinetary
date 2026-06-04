import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'controllers/app_provider.dart';
import 'controllers/auth_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wrap Firebase initialization to avoid crashing the Dart isolate
  // if a native plugin or configuration causes an exception at startup.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
      );
    }
  } catch (e, st) {
    // Log the error so we can debug native init issues without crashing.
    // Keep app running to verify UI rendering (MainNavigationView).
    debugPrint('Firebase initialization failed: $e');
    debugPrint('$st');
  }

  runApp(const ItinetaryApp());
}

class ItinetaryApp extends StatelessWidget {
  const ItinetaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Use named routes consistently. Do not specify `home` when
        // the routes table contains an entry for '/'. Use `initialRoute`.
        initialRoute: AppRoutes.splash,
        routes: AppRouter.routes,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
