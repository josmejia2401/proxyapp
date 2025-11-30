import 'dart:async';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';
import '../domain/device_info.dart';

class ClientTracker {
  /// Mapa de dispositivos conectados, indexado por IP.
  final Map<String, DeviceInfo> devices = {};

  /// Stream para emitir cambios en tiempo real a la UI.
  final StreamController<List<DeviceInfo>> _stream =
      StreamController<List<DeviceInfo>>.broadcast();

  Stream<List<DeviceInfo>> get stream => _stream.stream;

  Timer? _speedTimer;

  /// Tiempo máximo para considerar un dispositivo "online"
  /// desde su última actividad.
  final Duration onlineTimeout = const Duration(seconds: 20);

  ClientTracker() {
    // Actualización de velocidades + estado online cada 1 segundo
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();

      for (final device in devices.values) {
        device.updateSpeed(); // recalcula Kbps basados en ventana de 1s

        final last = device.lastActivity ?? device.lastConnection;

        if (last != null && now.difference(last) > onlineTimeout) {
          device.online = false;
        }
      }

      _push();
    });
  }

  /// Notifica a listeners que hubo cambios en los dispositivos
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
    saveStats(); // persistimos
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

  List<DeviceInfo> get devicesList => devices.values.toList(growable: false);

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
    final raw = await CacheService.instance.readJson(
      "devices_stats",
    ); // OJO: await
    if (raw == null) return;

    raw.forEach((ip, dJson) {
      devices[ip] = DeviceInfo.fromJson(Map<String, dynamic>.from(dJson));
    });

    _push();
  }
}
