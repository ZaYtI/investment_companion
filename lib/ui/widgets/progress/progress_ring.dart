import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget child;

  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    required this.child,
    this.size = 110,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0, 1),
          color: color,
          strokeWidth: strokeWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
  });

  static const startAngle = -pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final track = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, track);
    canvas.drawArc(rect, startAngle, 2 * pi * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
