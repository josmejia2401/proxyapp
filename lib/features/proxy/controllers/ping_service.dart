import 'dart:io';

class PingService {
  Future<int> ping(String ip) async {
    final sw = Stopwatch()..start();
    try {
      final socket = await Socket.connect(ip, 80, timeout: Duration(seconds: 1));
      socket.destroy();
      sw.stop();
      return sw.elapsedMilliseconds;
    } catch (_) {
      return -1;
    }
  }
}
