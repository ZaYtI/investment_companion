import 'package:flutter/material.dart';

class CubeIcon extends StatelessWidget {
  final Color color;
  final double size;

  const CubeIcon({super.key, required this.color, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CubePainter(color: color),
    );
  }
}

class _CubePainter extends CustomPainter {
  final Color color;

  _CubePainter({required this.color});

  static const lighterAmount = 0.5;
  static const darkerAmount = 0.15;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final top = Offset(width / 2, 0);
    final left = Offset(0, height * 0.25);
    final right = Offset(width, height * 0.25);
    final center = Offset(width / 2, height * 0.5);
    final bottomLeft = Offset(0, height * 0.75);
    final bottomRight = Offset(width, height * 0.75);
    final bottom = Offset(width / 2, height);

    _drawFace(canvas, [
      top,
      right,
      center,
      left,
    ], Color.lerp(color, Colors.white, lighterAmount)!);
    _drawFace(canvas, [left, center, bottom, bottomLeft], color);
    _drawFace(canvas, [
      center,
      right,
      bottomRight,
      bottom,
    ], Color.lerp(color, Colors.black, darkerAmount)!);
  }

  void _drawFace(Canvas canvas, List<Offset> corners, Color faceColor) {
    canvas.drawPath(
      Path()..addPolygon(corners, true),
      Paint()..color = faceColor,
    );
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => oldDelegate.color != color;
}
