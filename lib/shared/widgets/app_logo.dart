import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final String assetPath;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 120.0,
    this.assetPath = 'assets/images/logo.png',
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // En caso de que la imagen no se cargue, muestra un placeholder simple
          return Icon(
            Icons.error_outline,
            size: size * 0.6,
            color: Colors.redAccent,
          );
        },
      ),
    );
  }
}
