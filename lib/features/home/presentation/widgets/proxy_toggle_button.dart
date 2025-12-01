import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import '../../../proxy/controllers/proxy_notifier.dart';

class ProxyToggleButton extends StatelessWidget {
  const ProxyToggleButton({super.key});

  Future<void> _startBackgroundServer(BuildContext context) async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
      service.invoke("start");
    }
    final proxy = context.read<ProxyNotifier>();
    await proxy.startServer();
  }

  Future<void> _stopBackgroundServer(BuildContext context) async {
    final service = FlutterBackgroundService();
    final proxy = context.read<ProxyNotifier>();

    proxy.stopServer();

    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke("stop");
    }
  }

  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();
    final running = proxy.isRunning;

    return GestureDetector(
      onTap: () {
        //running ? proxy.stopServer() : proxy.startServer();
        if (running) {
          _stopBackgroundServer(context);
        } else {
          _startBackgroundServer(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: running ? Colors.red.shade50 : Colors.green.shade50,
          boxShadow: running
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
        ),

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween<double>(begin: 0.5, end: 1).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            running
                ? Icons.stop_circle_rounded
                : Icons.play_circle_fill_rounded,
            key: ValueKey(running),
            size: 30,
            color: running ? Colors.redAccent : Colors.green,
          ),
        ),
      ),
    );
  }
}
