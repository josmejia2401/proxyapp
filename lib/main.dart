import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';
import 'package:proxyapp/features/proxy/controllers/client_tracker.dart';
import 'package:proxyapp/features/proxy/controllers/proxy_notifier.dart';
import 'package:proxyapp/features/proxy/controllers/system_stats_service.dart';
import 'package:proxyapp/routes.dart';
import 'package:proxyapp/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await CacheService.instance.init();

  final tracker = ClientTracker();
  final system = SystemStatsService();
  final proxyNotifier = ProxyNotifier(tracker, system);
  proxyNotifier.loadBlocked();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProxyNotifier>.value(value: proxyNotifier),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProxyApp',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
