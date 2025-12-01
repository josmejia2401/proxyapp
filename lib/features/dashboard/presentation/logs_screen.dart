import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../proxy/controllers/proxy_notifier.dart';
import 'package:proxyapp/core/constants/app_colors.dart';

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
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      final max = scrollController.position.maxScrollExtent;
      final offset = scrollController.offset;

      // El usuario está arriba → NO autoscroll
      _shouldAutoScroll = (max - offset) < 80;
    });
  }

  void _scrollToEnd() {
    if (!_shouldAutoScroll) return;
    if (!scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
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
    final proxy = context.read<ProxyNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs del Proxy"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => proxy.clearLogs(),
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
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar logs...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (t) => setState(() => _search = t),
            ),
          ),

          Expanded(
            child: StreamBuilder<String>(
              stream: proxy.logsStream,
              builder: (_, snap) {
                final raw = proxy.logs;
                final filtered = _applyFilters(raw);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToEnd();
                });

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      "No hay logs para mostrar",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final log = filtered[i];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(log.icon, color: log.color, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              log,
                              style: TextStyle(
                                fontSize: 13,
                                color: log.color,
                                fontFamily: "monospace",
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
