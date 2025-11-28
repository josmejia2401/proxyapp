import 'package:flutter/material.dart';
import 'package:proxyapp/core/constants/app_colors.dart';
import 'package:proxyapp/core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.transparent : AppColors.primary,
      foregroundColor: isOutlined ? AppColors.primary : Colors.white,
      side: isOutlined ? BorderSide(color: AppColors.primary) : BorderSide.none,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(text, style: AppTextStyles.buttonText),
    );
  }
}
