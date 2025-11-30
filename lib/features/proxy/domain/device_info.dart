class DeviceInfo {
  final String ip;

  bool online = false;

  int totalDownload = 0;
  int totalUpload = 0;

  int _windowDownBytes = 0;
  int _windowUpBytes = 0;

  double speedDown = 0; // bytes/s
  double speedUp = 0;   // bytes/s

  DateTime? lastConnection;
  DateTime? lastDisconnect;

  String? macAddress;
  String? deviceName;
  int? remotePort;

  String? userAgent;
  String? lastRequest;
  String? lastDomain;

  bool blocked = false;

  DateTime? lastActivity;

  DeviceInfo(this.ip);

  /// 🔹 Llamado por ClientTracker.addDownload
  void consumeDownload(int bytes) {
    totalDownload += bytes;
    _windowDownBytes += bytes;
  }

  /// 🔹 Llamado por ClientTracker.addUpload
  void consumeUpload(int bytes) {
    totalUpload += bytes;
    _windowUpBytes += bytes;
  }

  /// 🔹 Llamado cada 1s por ClientTracker (Timer)
  void updateSpeed() {
    speedDown = _windowDownBytes.toDouble(); // bytes en el último segundo
    speedUp = _windowUpBytes.toDouble();
    _windowDownBytes = 0;
    _windowUpBytes = 0;
  }

  double get speedDownKbps => speedDown / 1024;
  double get speedUpKbps => speedUp / 1024;

  Map<String, dynamic> toJson() {
    return {
      "ip": ip,
      "online": online,
      "totalDownload": totalDownload,
      "totalUpload": totalUpload,
      "speedDown": speedDown,
      "speedUp": speedUp,
      "lastConnection": lastConnection?.toIso8601String(),
      "lastDisconnect": lastDisconnect?.toIso8601String(),
      "macAddress": macAddress,
      "deviceName": deviceName,
      "remotePort": remotePort,
      "userAgent": userAgent,
      "lastRequest": lastRequest,
      "lastDomain": lastDomain,
      "blocked": blocked,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    final d = DeviceInfo(json["ip"]);

    d.online = json["online"] ?? false;
    d.totalDownload = json["totalDownload"] ?? 0;
    d.totalUpload = json["totalUpload"] ?? 0;

    d.speedDown = (json["speedDown"] ?? 0).toDouble();
    d.speedUp = (json["speedUp"] ?? 0).toDouble();

    d.lastConnection = json["lastConnection"] != null
        ? DateTime.tryParse(json["lastConnection"])
        : null;

    d.lastDisconnect = json["lastDisconnect"] != null
        ? DateTime.tryParse(json["lastDisconnect"])
        : null;

    d.macAddress = json["macAddress"];
    d.deviceName = json["deviceName"];
    d.remotePort = json["remotePort"];
    d.userAgent = json["userAgent"];
    d.lastRequest = json["lastRequest"];
    d.lastDomain = json["lastDomain"];

    d.blocked = json["blocked"] ?? false;

    return d;
  }
}
