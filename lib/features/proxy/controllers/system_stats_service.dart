import 'dart:io';
import 'package:proxyapp/features/proxy/domain/client_tracker.dart';

class SystemStatsService {
  SystemStatsService();

  Future<double> getCpuUsage() async {
    try {
      final stat1 = await File('/proc/stat').readAsLines();
      await Future.delayed(const Duration(milliseconds: 200));
      final stat2 = await File('/proc/stat').readAsLines();

      List<int> parse(List<String> lines) {
        final cpu = lines.first.split(RegExp(r'\s+'));
        return cpu.skip(1).map(int.parse).toList();
      }

      final a = parse(stat1);
      final b = parse(stat2);

      final idle = b[3] - a[3];
      final total = b.reduce((x, y) => x + y) - a.reduce((x, y) => x + y);

      return (1 - (idle / total)) * 100;
    } catch (_) {
      return 0;
    }
  }

  Future<double> getRamUsed() async {
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

      final used = total - available; // KB usados
      return used / 1024; // MB
    } catch (_) {
      return 0;
    }
  }

  Future<SystemStats> readStats() async {
    final cpu = await getCpuUsage();
    final ram = await getRamUsed();

    return SystemStats(cpu: cpu, ram: ram);
  }
}
