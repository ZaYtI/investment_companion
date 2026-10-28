import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color background;
  final Color foreground;

  const AppBadge.text(
    String this.text, {
    super.key,
    this.background = AppColors.background,
    this.foreground = AppColors.textPrimary,
  }) : icon = null;

  const AppBadge.icon(
    IconData this.icon, {
    super.key,
    this.background = AppColors.background,
    this.foreground = AppColors.textPrimary,
  }) : text = null;

  static const size = 44.0;
  static const radius = 12.0;
  static const horizontalPadding = 8.0;
  static const iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: icon != null
          ? Icon(icon, size: iconSize, color: foreground)
          : Text(
              text!,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
    );
  }
}
