import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../proxy/controllers/proxy_notifier.dart';
import '../../proxy/domain/device_info.dart';

class DeviceEditScreen extends StatelessWidget {
  final DeviceInfo device;

  DeviceEditScreen({required this.device});

  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Dispositivo"),
        centerTitle: true,
        elevation: 2,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _infoTile("IP", device.ip, Icons.language),
          _infoTile("MAC", device.macAddress ?? "No disponible", Icons.confirmation_number),
          _infoTile("Nombre", device.deviceName ?? "Desconocido", Icons.devices),
          _infoTile("Último dominio", device.lastDomain ?? "N/A", Icons.public),
          _infoTile("Última actividad", device.lastRequest ?? "N/A", Icons.access_time),

          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text("Bloqueado"),
            value: device.blocked ?? false,
            activeColor: Colors.red,
            onChanged: (v) {
              v ? proxy.block(device.ip) : proxy.unblock(device.ip);
            },
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
