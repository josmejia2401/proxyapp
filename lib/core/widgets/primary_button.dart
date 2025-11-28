import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool enabled;
  final bool loading;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.loading = false,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled && !loading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor:
            foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
        elevation: 2,
      ),
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color:
                    foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color:
                        foregroundColor ??
                        Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
    );
  }
}
