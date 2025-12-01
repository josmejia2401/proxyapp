import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';
import 'package:proxyapp/features/proxy/controllers/client_tracker.dart';
import 'package:proxyapp/features/proxy/controllers/proxy_notifier.dart';
import 'package:proxyapp/features/proxy/controllers/system_stats_service.dart';
import 'package:proxyapp/features/proxy/firewall/firewall_service.dart';
import 'package:proxyapp/routes.dart';
import 'package:proxyapp/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

const notificationChannelId = "proxy_server_channel";
const notificationId = 24011991;

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await CacheService.instance.init();

  await initializeService();

  final tracker = ClientTracker();
  final system = SystemStatsService();
  final firewall = FirewallService();
  final proxyNotifier = ProxyNotifier(tracker, system, firewall);

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

// Background
Future<void> initializeService() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await localNotifications.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'ProxyApp Background Service',
    description: 'Notificación persistente del servidor proxy',
    importance: Importance.high,
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: "ProxyApp",
      initialNotificationContent: "Servidor detenido",
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
      foregroundServiceNotificationId: notificationId,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  debugPrint("OKOK Entro aqui");
  if (service is AndroidServiceInstance) {
    debugPrint("Entro aqui");
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "ProxyApp",
      content: "Servidor ejecutándose…",
    );
  }

  Timer.periodic(const Duration(seconds: 1), (_) async {
    if (service is AndroidServiceInstance &&
        await service.isForegroundService()) {
      await localNotifications.show(
        notificationId,
        'Servidor Activo',
        'Última actualización: ${DateTime.now().toIso8601String()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'ProxyApp Background',
            icon: '@mipmap/ic_launcher',
            ongoing: true,
            enableVibration: false,
            playSound: false,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  service.on("stop").listen((event) {
    debugPrint("background process is now stopped");
    service.stopSelf();
  });

  service.on("start").listen((event) {
    debugPrint("background process is now started");
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
