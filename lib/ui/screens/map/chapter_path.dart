import 'package:flutter/material.dart';

class ChapterPathPainter extends CustomPainter {
  final Color color;
  final Offset start;
  final Offset end;

  ChapterPathPainter({
    required this.color,
    required this.start,
    required this.end,
  });

  static const dotRadius = 2.0;
  static const dotSpacing = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final middleY = (start.dy + end.dy) / 2;
    final curve = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx, middleY, end.dx, middleY, end.dx, end.dy);

    final paint = Paint()..color = color;
    for (final metric in curve.computeMetrics()) {
      for (
        var distance = 0.0;
        distance < metric.length;
        distance += dotSpacing
      ) {
        final position = metric.getTangentForOffset(distance)!.position;
        canvas.drawCircle(position, dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ChapterPathPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.start != start ||
      oldDelegate.end != end;
}
