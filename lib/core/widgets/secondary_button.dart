import 'package:flutter/material.dart';
import 'package:proxyapp/core/constants/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool habilitado;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: habilitado,
      child: OutlinedButton(
        onPressed: habilitado ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: habilitado
              ? AppColors.textPrimary
              : AppColors.textSecondary,
          side: BorderSide(
            color: habilitado ? AppColors.primaryDark : AppColors.border,
            width: 1.8,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
