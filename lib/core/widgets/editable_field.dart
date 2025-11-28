import 'package:flutter/material.dart';
import 'package:proxyapp/core/constants/app_colors.dart';

class EditableField extends StatelessWidget {
  FocusNode focusNode = FocusNode();

  final TextEditingController controller;
  final String label;
  final bool editable;
  final String hint;
  final List<String? Function(String?)>? validators;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextStyle? textStyle;

  // Opcionales
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextInputType? keyboardType;

  EditableField({
    super.key,
    required this.controller,
    required this.label,
    required this.editable,
    required this.hint,
    this.validators,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding,
    this.hintStyle,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? 28.0;
    final defaultTextStyle =
        textStyle ??
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary);
    TextStyle? defaultHintStyle =
        hintStyle ??
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint);

    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      enabled: editable,
      obscureText: obscureText,
      style: defaultTextStyle,
      keyboardType: keyboardType,
      validator: validators != null
          ? (value) {
              for (final validator in validators!) {
                final result = validator(value);
                if (result != null) return result;
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        hintText: hint,
        hintStyle: focusNode.hasFocus
            ? defaultHintStyle?.copyWith(color: AppColors.primary)
            : defaultHintStyle,
        //prefixIcon: prefixIcon,
        suffixIcon: suffixIcon != null
            ? IconTheme(
                data: IconThemeData(color: AppColors.iconPrimary),
                child: suffixIcon!,
              )
            : null,
        filled: true,
        fillColor: backgroundColor ?? AppColors.fieldBackground,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(vertical: 17, horizontal: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.borderFocus),
        ),

        errorStyle: const TextStyle(color: AppColors.error),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: IconThemeData(color: AppColors.iconPrimary),
                child: prefixIcon!,
              )
            : null,
      ),
    );
  }
}
