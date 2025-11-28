import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../proxy/controllers/proxy_notifier.dart';
import 'package:proxyapp/core/constants/app_colors.dart';

// =====================================================
// EXTENSIONES: tipo de log + color + ícono
// =====================================================

enum LogType { error, connect, request, response, client, server, other }

extension LogInfo on String {
  LogType get type {
    final l = toLowerCase();

    if (l.contains("error") || l.contains("❌")) return LogType.error;
    if (l.contains("connect") || l.contains("túnel")) return LogType.connect;
    if (l.contains("request") || l.contains("➡")) return LogType.request;
    if (l.contains("respuesta") || l.contains("⬅")) return LogType.response;
    if (l.contains("cliente")) return LogType.client;
    if (l.contains("proxy") || l.contains("servidor")) return LogType.server;

    return LogType.other;
  }

  Color get color {
    switch (type) {
      case LogType.error:
        return Colors.redAccent;
      case LogType.connect:
        return Colors.orange;
      case LogType.request:
        return Colors.blueAccent;
      case LogType.response:
        return Colors.green;
      case LogType.client:
        return Colors.deepPurple;
      case LogType.server:
        return Colors.teal;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData get icon {
    switch (type) {
      case LogType.error:
        return Icons.error;
      case LogType.connect:
        return Icons.vpn_lock;
      case LogType.request:
        return Icons.north_east;
      case LogType.response:
        return Icons.south_west;
      case LogType.client:
        return Icons.devices;
      case LogType.server:
        return Icons.dns;
      default:
        return Icons.bubble_chart;
    }
  }
}

// =====================================================
// PANTALLA PRINCIPAL
// =====================================================

class LogsScreen extends StatefulWidget {
  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final scrollController = ScrollController();

  String _search = "";
  LogType? _filterType;

  @override
  void initState() {
    super.initState();

    // Auto scroll al final cuando llega un log nuevo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proxy = context.read<ProxyNotifier>();
      proxy.logsStream.listen((_) => _scrollToEnd());
    });
  }

  void _scrollToEnd() {
    if (!scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 60), () {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _copyAllLogs(List<String> logs) {
    Clipboard.setData(ClipboardData(text: logs.join("\n")));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logs copiados al portapapeles"),
        backgroundColor: Colors.black87,
      ),
    );
  }

  List<String> _applyFilters(List<String> original) {
    return original.where((log) {
      if (_search.isNotEmpty &&
          !log.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }

      if (_filterType != null && log.type != _filterType) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();
    final logs = proxy.logs;

    final filteredLogs = _applyFilters(logs);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs del Proxy"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: "Copiar todos los logs",
            onPressed: () => _copyAllLogs(filteredLogs),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Borrar logs",
            onPressed: () => context.read<ProxyNotifier>().clearLogs(),
          ),
          PopupMenuButton<LogType?>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (v) => setState(() => _filterType = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text("Todos")),
              const PopupMenuItem(value: LogType.error, child: Text("Errores")),
              const PopupMenuItem(value: LogType.connect, child: Text("CONNECT")),
              const PopupMenuItem(value: LogType.request, child: Text("Requests")),
              const PopupMenuItem(value: LogType.response, child: Text("Responses")),
              const PopupMenuItem(value: LogType.client, child: Text("Cliente")),
              const PopupMenuItem(value: LogType.server, child: Text("Proxy/Server")),
            ],
          )
        ],
      ),

      body: Column(
        children: [
          // =====================================================
          // BUSCADOR
          // =====================================================
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.iconPrimary),
                hintText: "Buscar logs...",
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (t) => setState(() => _search = t),
            ),
          ),

          // =====================================================
          // LISTA DE LOGS
          // =====================================================
          Expanded(
            child: Container(
              color: AppColors.surfaceVariant,
              child: filteredLogs.isEmpty
                  ? Center(
                child: Text(
                  "No hay logs para mostrar",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: filteredLogs.length,
                itemBuilder: (_, index) {
                  final log = filteredLogs[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(log.icon, color: log.color, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectableText(
                            log,
                            style: TextStyle(
                              color: log.color,
                              fontSize: 13,
                              fontFamily: "monospace",
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
