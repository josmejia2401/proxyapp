import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';

import '../../proxy/controllers/proxy_notifier.dart';
import '../../home/presentation/widgets/proxy_toggle_button.dart';
import 'proxy_settings_edit_screen.dart';

class ProxySettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración del Proxy"),
        centerTitle: true,
        elevation: 2,
        actions: [ProxyToggleButton()],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _sectionTitle("Información del servidor"),

          _infoCard(
            icon: Icons.power_settings_new,
            label: "Estado del Servidor",
            value: proxy.isRunning ? "Activo" : "Detenido",
            valueColor: proxy.isRunning ? Colors.green : Colors.red,
          ),

          _infoCard(
            icon: Icons.router,
            label: "Puerto actual",
            value: proxy.port.toString(),
          ),

          const SizedBox(height: 24),
          _sectionTitle("Ajustes"),

          /// Cambiar puerto
          _editableCard(
            context,
            icon: Icons.tune,
            label: "Cambiar Puerto",
            subtitle: "Editar el puerto del proxy",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProxySettingsEditScreen()),
            ),
          ),

          const SizedBox(height: 12),

          /// NUEVA OPCIÓN: LIMPIAR CACHÉ
          _editableCard(
            context,
            icon: Icons.delete_forever,
            label: "Limpiar Caché",
            subtitle: "Eliminar estadísticas, dispositivos y bloqueos",
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("¿Limpiar caché?"),
                  content: const Text(
                    "Se eliminarán dispositivos, estadísticas, datos "
                        "persistidos y la lista de bloqueados.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Limpiar"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await CacheService.instance.clearAll();

                /// Reiniciar datos del notifier
                proxy.clearCache();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Caché limpiada correctamente"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// ========================================
/// WIDGETS REUSABLES
/// ========================================

Widget _sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );
}

Widget _infoCard({
  required IconData icon,
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.withOpacity(0.15),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget _editableCard(
    BuildContext context, {
      required IconData icon,
      required String label,
      required String subtitle,
      required VoidCallback onTap,
    }) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 26),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}
