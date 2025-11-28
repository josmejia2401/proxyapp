import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:proxyapp/features/proxy/controllers/client_tracker.dart';
import 'package:proxyapp/features/proxy/controllers/system_stats_service.dart';
import 'package:proxyapp/features/proxy/controllers/proxy_notifier.dart';
import 'package:proxyapp/features/proxy/controllers/proxy_server.dart';

class ProxyTaskHandler extends TaskHandler {
  ProxyServer? server;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Reinicia todo en background
    final tracker = ClientTracker();
    final system = SystemStatsService();
    final notifier = ProxyNotifier(tracker, system);
    server = ProxyServer(tracker, notifier);

    // Puerto fijo o configurable
    await server!.start(port: notifier.port);
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Puedes enviar estadísticas, guardar logs, etc.
    print("⏱ Background tick: $timestamp");
  }

  /// 🔹 Cuando se detiene el servicio (app cerrada, usuario apaga proxy, etc.)
  @override
  Future<void> onDestroy(DateTime timestamp, bool isForeground) async {
    print("🛑 ProxyTaskHandler: onDestroy (isForeground: $isForeground)");

    await server?.stop();
  }
}
