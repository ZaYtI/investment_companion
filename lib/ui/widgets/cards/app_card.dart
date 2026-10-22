import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.borderColor,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  static const borderRadius = BorderRadius.all(Radius.circular(16));
  static const defaultBorderWidth = 1.0;
  static const highlightedBorderWidth = 2.0;
  static const bottomEdgeHeight = 3.0;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = borderColor != null;
    return Semantics(
      button: onTap != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor ?? AppColors.border,
            width: isHighlighted ? highlightedBorderWidth : defaultBorderWidth,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(0, bottomEdgeHeight),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
