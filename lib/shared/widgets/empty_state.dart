import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? imageAssetPath;
  final double imageWidth;
  final double imageHeight;
  final TextStyle? messageStyle;

  const EmptyState({
    super.key,
    required this.message,
    this.imageAssetPath,
    this.imageWidth = 100,
    this.imageHeight = 100,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Colors.grey);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (imageAssetPath != null)
            Image.asset(
              imageAssetPath!,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey,
              ),
            ),
          SizedBox(height: imageAssetPath != null ? 16 : 0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: messageStyle ?? defaultTextStyle,
          ),
        ],
      ),
    );
  }
}
