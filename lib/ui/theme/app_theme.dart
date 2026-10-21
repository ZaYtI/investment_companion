import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

abstract final class AppTheme {
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.mintText,
    onPrimary: AppColors.surface,
    primaryContainer: AppColors.mintPale,
    onPrimaryContainer: AppColors.mintText,
    secondary: AppColors.gold,
    onSecondary: AppColors.textPrimary,
    tertiary: AppColors.mint,
    onTertiary: AppColors.textPrimary,
    error: AppColors.redText,
    onError: AppColors.surface,
    errorContainer: AppColors.coralPale,
    onErrorContainer: AppColors.redText,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.background,
    surfaceContainerHigh: AppColors.border,
    surfaceContainerHighest: AppColors.border,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    inverseSurface: AppColors.mapNight,
    onInverseSurface: AppColors.surface,
    shadow: AppColors.textPrimary,
  );

  static ThemeData get light {
    final base = ThemeData(
      colorScheme: colorScheme,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
    );
    final text = base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: _title(text.displayLarge, FontWeight.w700),
        displayMedium: _title(text.displayMedium, FontWeight.w700),
        displaySmall: _title(text.displaySmall, FontWeight.w700),
        headlineLarge: _title(text.headlineLarge, FontWeight.w700),
        headlineMedium: _title(text.headlineMedium, FontWeight.w700),
        headlineSmall: _title(text.headlineSmall, FontWeight.w700),
        titleLarge: _title(text.titleLarge, FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textSecondary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mint,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),
    );
  }

  static TextStyle? _title(TextStyle? style, FontWeight weight) =>
      style?.copyWith(fontFamily: AppFonts.titles, fontWeight: weight);
}
