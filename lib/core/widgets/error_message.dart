import 'package:flutter/material.dart';
import 'package:proxyapp/core/constants/app_colors.dart';
import 'package:proxyapp/core/constants/app_text_styles.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
