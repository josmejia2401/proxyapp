import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';
import 'package:proxyapp/features/proxy/controllers/system_stats_service.dart';
import 'client_tracker.dart';
import 'proxy_server.dart';

class ProxyNotifier extends ChangeNotifier {
  final ClientTracker tracker;
  final SystemStatsService statsService;

  ProxyServer? _server;

  bool _isRunning = false;
  int _port = 8080;
  final List<String> _logs = [];
  final StreamController<List<String>> _logStream =
      StreamController<List<String>>.broadcast();
  String? _errorMessage;
  Set<String> _blocked = {};
  final CacheService cache = CacheService.instance;

  ProxyNotifier(this.tracker, this.statsService) {
    _loadState();
  }

  bool get isRunning => _isRunning;
  int get port => _port;
  String? get errorMessage => _errorMessage;
  Set<String> get blocked => _blocked;

  bool isBlocked(String ip) => _blocked.contains(ip);

  List<String> get logs => _logs;
  Stream<List<String>> get logsStream => _logStream.stream;

  void block(String ip) async {
    _blocked.add(ip);
    tracker.devices[ip]?.blocked = true;
    notifyListeners();
    await cache.writeList("blocked_ips", blocked.toList());
    addLog("⛔ Dispositivo bloqueado $ip");
  }

  void unblock(String ip) async {
    _blocked.remove(ip);
    tracker.devices[ip]?.blocked = false;
    notifyListeners();
    await cache.writeList("blocked_ips", blocked.toList());
    addLog("✔️ Dispositivo desbloqueado $ip");
  }

  void setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<void> startServer() async {
    if (_isRunning) return;

    try {
      _server = ProxyServer(tracker, this);
      await _server!.start(port: _port);

      _isRunning = true;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      setError("Error al iniciar server: $e");
    }
  }

  Future<void> stopServer() async {
    if (!_isRunning) return;

    try {
      await _server?.stop();
      _isRunning = false;

      notifyListeners();
    } catch (e) {
      setError("Error al detener server: $e");
    }
  }

  void onServerStarted() {
    _isRunning = true;
    notifyListeners();
  }

  void onServerStopped() {
    _isRunning = false;
    FlutterForegroundTask.stopService();
    notifyListeners();
  }

  Future<void> setPort(int newPort) async {
    if (newPort <= 0 || newPort > 65535) {
      setError("Puerto inválido");
      return;
    }

    _port = newPort;
    notifyListeners();

    if (_isRunning) {
      await stopServer();
      await startServer();
    }
  }

  void clearLogs() {
    _logs.clear();
    _logStream.add(_logs);
    notifyListeners();
  }

  void addLog(String msg) {
    final now = DateTime.now();
    final stamp =
        "[${now.hour.toString().padLeft(2, "0")}:"
        "${now.minute.toString().padLeft(2, "0")}:"
        "${now.second.toString().padLeft(2, "0")}]";

    final log = "$stamp $msg";

    _logs.add(log);

    if (_logs.length > 30) {
      _logs.removeAt(0);
    }

    _logStream.add(_logs);
    notifyListeners();
  }

  void clearCache() {
    logs.clear();
    blocked.clear();
    tracker.devices.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    tracker.dispose();
    super.dispose();
  }

  Future _loadState() async {
    await CacheService.instance.init();
    await tracker.loadStats();
    final saved = cache.readList("blocked_ips");
    _blocked = saved.toSet();
    notifyListeners();
  }
}
