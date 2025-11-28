import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../proxy/controllers/proxy_notifier.dart';

class ProxyToggleButton extends StatelessWidget {
  const ProxyToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();
    final running = proxy.isRunning;

    return GestureDetector(
      onTap: () {
        running ? proxy.stopServer() : proxy.startServer();
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
            // Glow roja elegante
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ]
              : [
            // Glow verde suave
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ],
        ),

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween<double>(begin: 0.5, end: 1).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            running ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
            key: ValueKey(running),
            size: 30,
            color: running ? Colors.redAccent : Colors.green,
          ),
        ),
      ),
    );
  }
}
