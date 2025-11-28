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

  ClientTracker() {
    // Actualización de velocidades cada 1 segundo
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      for (final device in devices.values) {
        device.updateSpeed(); // recalcula Kbps basados en ventana de 1s
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

  // ==============================================
  // 🔵 Registrar conexión
  // ==============================================
  void registerConnection(
      String ip, {
        String? macAddress,
        String? deviceName,
        int? port,
      }) {
    devices.putIfAbsent(ip, () => DeviceInfo(ip));

    final d = devices[ip]!;

    d.online = true;
    d.lastConnection = DateTime.now();
    d.macAddress = macAddress ?? d.macAddress;
    d.deviceName = deviceName ?? d.deviceName;
    d.remotePort = port ?? d.remotePort;

    _push();
  }

  // ==============================================
  // 🔴 Registrar desconexión
  // ==============================================
  void registerDisconnect(String ip) {
    final d = devices[ip];
    if (d == null) return;

    d.online = false;
    d.lastDisconnect = DateTime.now();

    _push();
  }

  // ==============================================
  // 📝 Actualizar metadata del cliente
  // ==============================================
  void updateClientMeta(
      String ip, {
        String? userAgent,
        String? firstLine,
      }) {
    final d = devices[ip];
    if (d == null) return;

    if (userAgent != null) d.userAgent = userAgent;
    if (firstLine != null) d.lastRequest = firstLine;

    _push();
  }

  void updateLastDomain(String ip, String host) {
    final d = devices[ip];
    if (d == null) return;

    d.lastDomain = host;
    _push();
  }

  // ==============================================
  // 📥 Registrar bytes descargados
  // ==============================================
  void addDownload(String ip, int bytes) {
    final d = devices[ip];
    if (d == null) return;

    d.consumeDownload(bytes);
    _push();
  }

  // ==============================================
  // 📤 Registrar bytes subidos
  // ==============================================
  void addUpload(String ip, int bytes) {
    final d = devices[ip];
    if (d == null) return;

    d.consumeUpload(bytes);
    _push();
  }

  // ==============================================
  // 📄 Lista inmutable para la UI
  // ==============================================
  List<DeviceInfo> get devicesList =>
      devices.values.toList(growable: false);

  // ==============================================
  // 🧹 Liberar recursos
  // ==============================================
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
    final raw = CacheService.instance.readJson("devices_stats");
    if (raw == null) return;

    raw.forEach((ip, dJson) {
      devices[ip] = DeviceInfo.fromJson(Map<String, dynamic>.from(dJson));
    });
  }
}
