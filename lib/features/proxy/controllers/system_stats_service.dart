import 'dart:io';
import 'package:proxyapp/features/proxy/domain/client_tracker.dart';
import 'package:flutter/services.dart';

class SystemStatsService {
  SystemStatsService();

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

  int openSockets() {
    try {
      final dir = Directory("/proc/self/fd");

      return dir.listSync().where((entity) {
        try {
          if (FileSystemEntity.typeSync(entity.path) !=
              FileSystemEntityType.link) {
            return false;
          }

          final target = File(entity.path).resolveSymbolicLinksSync();

          return target.startsWith('socket:[');
        } catch (_) {
          return false;
        }
      }).length;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getCpuUsageSafe() async {
    try {
      final stat1 = await File('/proc/self/stat').readAsString();
      await Future.delayed(Duration(milliseconds: 500));
      final stat2 = await File('/proc/self/stat').readAsString();

      final parts1 = stat1.split(' ');
      final parts2 = stat2.split(' ');

      final utime1 = int.parse(parts1[13]);
      final stime1 = int.parse(parts1[14]);
      final utime2 = int.parse(parts2[13]);
      final stime2 = int.parse(parts2[14]);

      final delta = (utime2 + stime2) - (utime1 + stime1);
      return (delta / 100) * 100; // % estimado
    } catch (_) {
      return 0.0;
    }
  }

  Future<SystemStats> readStats() async {
    final ramSystem = await getSystemRamUsedMb();
    final ramApp = await getAppMemoryMb();
    final countTask = openSockets();
    final cpu = await getCpuUsageSafe();
    final appCpu = 0.0;

    return SystemStats(
      cpu: cpu,
      ram: ramSystem,
      appMemory: ramApp,
      countTask: countTask,
      appCpu: appCpu,
    );
  }
}
