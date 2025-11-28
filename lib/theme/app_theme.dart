import 'package:flutter/material.dart';
import 'package:proxyapp/core/constants/app_colors.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    secondaryContainer: AppColors.accent,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
    onPrimary: AppColors.textPrimary,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textSecondary,
    onBackground: AppColors.textSecondary,
    onError: AppColors.textPrimary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.surface,
  disabledColor: AppColors.backgroundDisabled,
  hintColor: AppColors.textHint,
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.fieldBackground,
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(10),
    ),
    hintStyle: TextStyle(color: AppColors.textHint),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: AppColors.textSecondary),
    titleMedium: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

);
