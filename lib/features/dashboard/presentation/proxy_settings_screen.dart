import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:proxyapp/features/proxy/controllers/cache_service.dart';
import 'package:proxyapp/features/proxy/controllers/proxy_notifier.dart';
import 'package:proxyapp/features/home/presentation/widgets/proxy_toggle_button.dart';
import 'proxy_settings_edit_screen.dart';
import 'package:proxyapp/core/constants/app_colors.dart';

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
          /// INFO
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

          /// AJUSTES
          _sectionTitle("Ajustes"),

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

          _editableCard(
            context,
            icon: Icons.delete_forever,
            label: "Limpiar Caché",
            subtitle: "Eliminar estadísticas y dispositivos",
            onTap: () => _confirmClearCache(context, proxy),
          ),
        ],
      ),
    );
  }

  /// ================================================================
  /// CONFIRMAR LIMPIEZA DE CACHÉ
  /// ================================================================
  Future<void> _confirmClearCache(
    BuildContext context,
    ProxyNotifier proxy,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Limpiar caché?"),
        content: const Text(
          "Esto eliminará:\n\n"
          "• Datos de dispositivos\n"
          "• Estadísticas de tráfico\n"
          "• IPs bloqueadas\n"
          "• Información persistida\n\n"
          "No se puede deshacer.",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Limpiar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CacheService.instance.clearAll();
      proxy.clearCache();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Caché limpiada correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// =================================================================
/// WIDGETS REUTILIZABLES
/// =================================================================

Widget _sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
        ],
      ),
    ),
  );
}
