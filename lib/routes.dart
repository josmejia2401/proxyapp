import 'package:flutter/material.dart';
import 'package:proxyapp/core/widgets/splash_screen.dart';
import 'package:proxyapp/features/home/presentation/home_tabs.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());

    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => HomeTabs());

    default:
      return _errorRoute();
  }
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Ruta no encontrada')),
    ),
  );
}
