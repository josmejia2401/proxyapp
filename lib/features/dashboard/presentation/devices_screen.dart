import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../proxy/controllers/proxy_notifier.dart';
import '../../proxy/domain/device_info.dart';
import '../../home/presentation/widgets/proxy_toggle_button.dart';
import 'device_edit_screen.dart';

class DevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();
    final devices = proxy.tracker.devicesList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispositivos"),
        centerTitle: true,
        elevation: 2,
        actions: [ProxyToggleButton()],
      ),

      body: devices.isEmpty
          ? _emptyPlaceholder()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              itemBuilder: (_, index) {
                final d = devices[index];
                return _deviceCard(context, d, proxy);
              },
            ),
    );
  }

  Widget _emptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No hay dispositivos conectados",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6),
            Text(
              "Los dispositivos aparecerán aquí cuando\nutilicen el proxy.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceCard(BuildContext context, DeviceInfo d, ProxyNotifier proxy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DeviceEditScreen(device: d)),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICONO
            CircleAvatar(
              radius: 30,
              backgroundColor: d.online
                  ? Colors.green.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              child: Icon(
                d.online ? Icons.wifi : Icons.wifi_off,
                color: d.online ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // COLUMNA EXPANDIDA (INFO)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.deviceName ?? "Dispositivo sin nombre",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.ip,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),

                  if (d.macAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "MAC: ${d.macAddress}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _speedBadge(Icons.download, d.speedDown),
                      _speedBadge(Icons.upload, d.speedUp),
                    ],
                  ),

                  if (d.lastDomain != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.public, size: 16, color: Colors.blue),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            d.lastDomain!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 70,
              child: Column(
                children: [
                  Switch(
                    value: !d.blocked,
                    activeColor: Colors.green,
                    onChanged: (v) {
                      v ? proxy.unblock(d.ip) : proxy.block(d.ip);
                    },
                  ),
                  Text(
                    d.blocked ? "Bloq." : "OK",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: d.blocked ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _speedBadge(IconData icon, double bytesPerSec) {
    final kb = (bytesPerSec / 1024).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            "$kb KB/s",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
