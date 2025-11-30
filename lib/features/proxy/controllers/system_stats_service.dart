import 'dart:io';
import 'package:proxyapp/features/proxy/domain/client_tracker.dart';

class SystemStatsService {
  SystemStatsService();

  /// -----------------------------
  /// RAM total usada del sistema
  /// -----------------------------
  Future<double> getSystemRamUsedMb() async {
    try {
      final meminfo = await File('/proc/meminfo').readAsLines();
      int total = 0;
      int available = 0;

      for (var line in meminfo) {
        if (line.startsWith("MemTotal:")) {
          total = int.parse(line.split(RegExp(r'\s+'))[1]); // KB
        }
        if (line.startsWith("MemAvailable:")) {
          available = int.parse(line.split(RegExp(r'\s+'))[1]); // KB
        }
      }

      if (total == 0) return 0;

      final usedKb = total - available;
      return usedKb / 1024; // MB
    } catch (_) {
      return 0;
    }
  }

  /// -----------------------------
  /// RAM usada por la app (Proceso)
  /// VmRSS = Resident Set Size
  /// -----------------------------
  Future<double> getAppMemoryMb() async {
    try {
      final lines = await File('/proc/self/status').readAsLines();

      for (var line in lines) {
        if (line.startsWith("VmRSS:")) {
          final kb = int.parse(line.split(RegExp(r'\s+'))[1]);
          return kb / 1024; // MB
        }
      }
    } catch (_) {}

    return 0;
  }

  /// -----------------------------
  /// Retornar stats combinados
  /// -----------------------------
  Future<SystemStats> readStats() async {
    final ramSystem = await getSystemRamUsedMb();
    final ramApp = await getAppMemoryMb();

    return SystemStats(
      cpu: 0,          // CPU NO DISPONIBLE → SIEMPRE 0
      ram: ramSystem, // RAM del sistema
      appMemory: ramApp, // RAM usada por tu app
    );
  }
}
