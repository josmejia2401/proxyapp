import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';
import 'package:proxyapp/features/proxy/controllers/system_stats_service.dart';
import 'package:proxyapp/features/proxy/firewall/firewall_service.dart';
import 'client_tracker.dart';
import 'proxy_server.dart';

class ProxyNotifier extends ChangeNotifier {
  final ClientTracker tracker;
  final SystemStatsService statsService;
  final FirewallService firewall;
  ProxyServer? _server;
  DateTime? _startTime;
  Timer? _uptimeTimer;

  bool _isRunning = false;
  int _port = 8080;

  Set<String> _blocked = {};
  final List<String> _logs = [];
  final CacheService cache = CacheService.instance;

  ProxyNotifier(this.tracker, this.statsService, this.firewall) {
    _loadState();
  }

  final StreamController<String> _logStream =
      StreamController<String>.broadcast();

  bool get isRunning => _isRunning;
  int get port => _port;
  Set<String> get blocked => _blocked;
  bool isBlocked(String ip) => _blocked.contains(ip);
  List<String> get logs => _logs;
  Stream<String> get logsStream => _logStream.stream;
  DateTime? get startTime => _startTime;

  Duration get uptime {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }

  void block(String ip) async {
    _blocked.add(ip);
    tracker.devices[ip]?.blocked = true;
    notifyListeners();
    await cache.writeList("blocked_ips", blocked.toList());
  }

  void unblock(String ip) async {
    _blocked.remove(ip);
    tracker.devices[ip]?.blocked = false;
    notifyListeners();
    await cache.writeList("blocked_ips", blocked.toList());
  }

  Future<void> startServer() async {
    if (_isRunning) return;

    try {
      _server = ProxyServer(tracker, this);
      await _server!.start(port: _port);

      _startTime = DateTime.now();
      _isRunning = true;

      notifyListeners();
    } catch (e) {
      debugPrint("Error al iniciar server: $e");
    }
  }

  Future<void> stopServer() async {
    if (!_isRunning) return;

    try {
      await _server?.stop();
      _isRunning = false;
      _startTime = null;
      notifyListeners();
    } catch (e) {
      debugPrint("Error al detener server: $e");
    }
  }

  void onServerStarted() {
    _isRunning = true;
    _startTime = DateTime.now();
    _uptimeTimer?.cancel();
    _uptimeTimer = Timer.periodic(Duration(seconds: 1), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  void onServerStopped() {
    _isRunning = false;
    _startTime = null;
    _uptimeTimer?.cancel();
    notifyListeners();
  }

  Future<void> setPort(int newPort) async {
    if (newPort <= 0 || newPort > 65535) {
      debugPrint("Puerto inválido");
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

    _logStream.add(log);
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

  void addBlockedDomain(String domain) {
    firewall.addDomain(domain);
    notifyListeners();
  }

  void removeBlockedDomain(String domain) {
    firewall.removeDomain(domain);
    notifyListeners();
  }

  void addKeyword(String keyword) {
    firewall.addKeyword(keyword);
    notifyListeners();
  }

  void removeKeyword(String keyword) {
    firewall.removeKeyword(keyword);
    notifyListeners();
  }
}
