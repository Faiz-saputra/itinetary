import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_provider.dart';
import '../core/constants/app_routes.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/main_navigation/main_navigation_view.dart';
import '../views/splash/splash_view.dart';

/// Centralized route generator for the app.
class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.splash: (_) => const SplashView(),
      AppRoutes.authLogin: (_) => const GuestRoute(child: LoginView()),
      AppRoutes.authRegister: (_) => const GuestRoute(child: RegisterView()),
      AppRoutes.authForgotPassword: (_) =>
          const GuestRoute(child: ForgotPasswordView()),
      AppRoutes.home: (_) => const ProtectedRoute(child: MainNavigationView()),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return _buildRoute(settings, builder);
    }

    return _buildRoute(settings, (_) => const SplashView());
  }

  static MaterialPageRoute _buildRoute(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return MaterialPageRoute(settings: settings, builder: builder);
  }
}

class ProtectedRoute extends StatelessWidget {
  const ProtectedRoute({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.settings.name != AppRoutes.authLogin) {
          Navigator.pushReplacementNamed(context, AppRoutes.authLogin);
        }
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}

class GuestRoute extends StatelessWidget {
  const GuestRoute({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
