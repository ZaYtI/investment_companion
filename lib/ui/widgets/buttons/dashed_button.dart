import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DashedActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconAlignment iconAlignment;
  final AlignmentGeometry alignment;

  const DashedActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.alignment = Alignment.center,
  });

  static const radius = 16.0;
  static const minHeight = 52.0;
  static const horizontalPadding = 20.0;
  static const iconSize = 24.0;
  static const fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      iconColor: AppColors.textSecondary,
      disabledForegroundColor: AppColors.dashedBorder,
      disabledIconColor: AppColors.dashedBorder,
      iconSize: iconSize,
      minimumSize: const Size.fromHeight(minHeight),
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: alignment,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      textStyle: Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontSize: fontSize, fontWeight: FontWeight.w700),
    );
    final labelText = Text(label, overflow: TextOverflow.ellipsis);

    return CustomPaint(
      painter: const _DashedBorderPainter(
        color: AppColors.dashedBorder,
        radius: radius,
      ),
      child: icon == null
          ? TextButton(onPressed: onPressed, style: style, child: labelText)
          : TextButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon),
              iconAlignment: iconAlignment,
              label: labelText,
            ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const strokeWidth = 2.0;
  static const dashLength = 6.0;
  static const gapLength = 4.5;

  @override
  void paint(Canvas canvas, Size size) {
    final border = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in (Path()..addRRect(border)).computeMetrics()) {
      for (
        var start = 0.0;
        start < metric.length;
        start += dashLength + gapLength
      ) {
        final end = min(start + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
