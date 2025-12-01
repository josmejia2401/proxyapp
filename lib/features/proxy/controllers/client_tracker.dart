import 'dart:async';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';
import '../domain/device_info.dart';

class ClientTracker {
  final Map<String, DeviceInfo> devices = {};
  final StreamController<List<DeviceInfo>> _stream = StreamController<List<DeviceInfo>>.broadcast();

  Timer? _speedTimer;
  int _activeRequests = 0;


  final Duration onlineTimeout = const Duration(seconds: 20);

  ClientTracker() {

    _speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();

      for (final device in devices.values) {
        device.updateSpeed();

        final last = device.lastActivity ?? device.lastConnection;

        if (last != null && now.difference(last) > onlineTimeout) {
          device.online = false;
        }
      }

      _push();
    });
  }


  int get activeRequests => _activeRequests;
  Stream<List<DeviceInfo>> get stream => _stream.stream;
  List<DeviceInfo> get devicesList => devices.values.toList(growable: false);

  void incrementActiveRequests() {
    _activeRequests++;
  }
  void decrementActiveRequests() {
    if (_activeRequests > 0) _activeRequests--;
  }

  void _push() {
    if (!_stream.isClosed) {
      _stream.add(devices.values.toList(growable: false));
    }
  }

  void _markActivity(DeviceInfo d) {
    d.lastActivity = DateTime.now();
    d.online = true;
  }

  void registerConnection(
    String ip, {
    String? macAddress,
    String? deviceName,
    int? port,
  }) {
    devices.putIfAbsent(ip, () => DeviceInfo(ip));

    final d = devices[ip]!;

    d.lastConnection = DateTime.now();
    d.macAddress = macAddress ?? d.macAddress;
    d.deviceName = deviceName ?? d.deviceName;
    d.remotePort = port ?? d.remotePort;

    _markActivity(d);
    _push();
    saveStats();
  }

  void registerDisconnect(String ip) {
    final d = devices[ip];
    if (d == null) return;

    d.lastDisconnect = DateTime.now();

    _push();
    saveStats();
  }

  void updateClientMeta(String ip, {String? userAgent, String? firstLine}) {
    final d = devices[ip];
    if (d == null) return;

    if (userAgent != null) d.userAgent = userAgent;
    if (firstLine != null) d.lastRequest = firstLine;

    _markActivity(d);
    _push();
  }

  void updateLastDomain(String ip, String host) {
    final d = devices[ip];
    if (d == null) return;

    d.lastDomain = host;
    _markActivity(d);
    _push();
  }

  void addDownload(String ip, int bytes) {
    final d = devices[ip];
    if (d == null) return;

    d.consumeDownload(bytes);
    _markActivity(d);
    _push();
  }

  void addUpload(String ip, int bytes) {
    final d = devices[ip];
    if (d == null) return;

    d.consumeUpload(bytes);
    _markActivity(d);
    _push();
  }



  void dispose() {
    _speedTimer?.cancel();
    _stream.close();
  }

  Future<void> saveStats() async {
    final Map<String, dynamic> json = {};

    devices.forEach((ip, d) {
      json[ip] = d.toJson();
    });

    await CacheService.instance.writeJson("devices_stats", json);
  }

  Future<void> loadStats() async {
    final raw = CacheService.instance.readJson(
      "devices_stats",
    );
    if (raw == null) return;

    raw.forEach((ip, dJson) {
      devices[ip] = DeviceInfo.fromJson(Map<String, dynamic>.from(dJson));
    });

    _push();
  }
}
