import 'dart:io';
import 'package:proxyapp/features/proxy/domain/client_tracker.dart';

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

  Future<SystemStats> readStats() async {
    final ramSystem = await getSystemRamUsedMb();
    final ramApp = await getAppMemoryMb();
    final countTask = openSockets();

    return SystemStats(
      cpu: 0,
      ram: ramSystem,
      appMemory: ramApp,
      countTask: countTask,
    );
  }
}
