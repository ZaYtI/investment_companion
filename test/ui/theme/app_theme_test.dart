import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/ui/theme/app_colors.dart';
import 'package:investment_companion/ui/theme/app_fonts.dart';
import 'package:investment_companion/ui/theme/app_theme.dart';

void main() {
  final text = AppTheme.light.textTheme;

  test('les titres utilisent Sora', () {
    for (final style in [
      text.displayLarge,
      text.headlineMedium,
      text.titleLarge,
    ]) {
      expect(style?.fontFamily, AppFonts.titles);
    }
  });

  test('le texte courant utilise DM Sans', () {
    for (final style in [text.bodyMedium, text.labelLarge, text.titleMedium]) {
      expect(style?.fontFamily, AppFonts.body);
    }
  });

  test('le fond et le texte suivent la palette', () {
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.background);
    expect(text.bodyMedium?.color, AppColors.textPrimary);
    expect(text.headlineMedium?.color, AppColors.textPrimary);
  });

  test('le bouton principal est doré', () {
    final style = AppTheme.light.filledButtonTheme.style!;
    expect(style.backgroundColor?.resolve({}), AppColors.gold);
    expect(style.foregroundColor?.resolve({}), AppColors.textPrimary);
    expect(
      style.backgroundColor?.resolve({WidgetState.disabled}),
      AppColors.border,
    );
  });

  test('les erreurs utilisent le rouge lisible en texte', () {
    expect(AppTheme.colorScheme.error, AppColors.redText);
  });
}
