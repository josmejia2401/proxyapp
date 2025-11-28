import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:proxyapp/features/proxy/domain/client_tracker.dart';

import '../../proxy/controllers/proxy_notifier.dart';
import '../../home/presentation/widgets/proxy_toggle_button.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _localIp = "0.0.0.0";
  String _appVersion = "—";

  @override
  void initState() {
    super.initState();
    _loadIp();
    _loadVersion();
  }

  Future<void> _loadIp() async {
    final ip = await getLocalIp();
    setState(() => _localIp = ip);
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = "${info.version}+${info.buildNumber}");
  }

  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();
    final devices = proxy.tracker.devicesList;

    final double down = devices.fold(0.0, (a, b) => a + b.speedDown);
    final double up = devices.fold(0.0, (a, b) => a + b.speedUp);

    final totalDown = devices.fold(0, (a, b) => a + b.totalDownload);
    final totalUp = devices.fold(0, (a, b) => a + b.totalUpload);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        elevation: 2,
        actions: [ProxyToggleButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadIp();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===========================
              /// ESTADO DEL PROXY
              /// ===========================
              _sectionTitle("Estado del Proxy"),

              _proxyStatusCard(
                isRunning: proxy.isRunning,
                ip: _localIp,
                port: proxy.port,
                version: _appVersion,
              ),

              const SizedBox(height: 22),

              _sectionTitle("Velocidad en Tiempo Real"),

              Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      icon: Icons.download,
                      label: "Descarga",
                      value: "${(down / 1024).toStringAsFixed(2)} KB/s",
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricCard(
                      icon: Icons.upload,
                      label: "Subida",
                      value: "${(up / 1024).toStringAsFixed(2)} KB/s",
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _sectionTitle("Consumo Total"),

              Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      icon: Icons.data_usage,
                      label: "Descargado",
                      value: "${(totalDown / 1e6).toStringAsFixed(2)} MB",
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricCard(
                      icon: Icons.cloud_upload,
                      label: "Subido",
                      value: "${(totalUp / 1e6).toStringAsFixed(2)} MB",
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _sectionTitle("Dispositivos conectados"),

              _metricCard(
                icon: Icons.devices,
                label: "Online",
                value: devices.where((d) => d.online).length.toString(),
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 22),

              _sectionTitle("Seguridad / Bloqueos"),

              _metricCard(
                icon: Icons.block,
                label: "Bloqueados",
                value: proxy.blocked.length.toString(),
                color: Colors.redAccent,
              ),

              const SizedBox(height: 22),

              _sectionTitle("KPI del Sistema"),

              FutureBuilder<SystemStats>(
                future: proxy.statsService.readStats(),
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final s = snap.data!;

                  return Column(
                    children: [
                      _metricCard(
                        icon: Icons.memory,
                        label: "CPU",
                        value: "${s.cpu.toStringAsFixed(1)} %",
                        color: Colors.orange,
                      ),
                      SizedBox(height: 12),
                      _metricCard(
                        icon: Icons.sd_storage,
                        label: "RAM usada",
                        value: "${s.ram.toStringAsFixed(1)} MB",
                        color: Colors.indigo,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _proxyStatusCard({
  required bool isRunning,
  required String ip,
  required int port,
  required String version,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isRunning ? Colors.green.shade50 : Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isRunning ? Colors.green : Colors.red),
      boxShadow: [
        BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.05)),
      ],
    ),
    child: Row(
      children: [
        Icon(
          isRunning ? Icons.check_circle : Icons.cancel,
          color: isRunning ? Colors.green : Colors.red,
          size: 40,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRunning ? "Servidor Activo" : "Detenido",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isRunning ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text("IP: $ip", style: const TextStyle(fontSize: 14)),
              Text("Puerto: $port", style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 6),

              Text(
                "Versión: $version",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _metricCard({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          offset: const Offset(0, 2),
          color: Colors.black.withOpacity(0.08),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<String> getLocalIp() async {
  try {
    final interfaces = await NetworkInterface.list();
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.address.startsWith("127")) {
          return addr.address;
        }
      }
    }
  } catch (_) {}
  return "0.0.0.0";
}
