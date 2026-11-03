import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class IslandPainter extends CustomPainter {
  final int chapterNumber;

  IslandPainter({required this.chapterNumber});

  static const buildingHeightsByChapter = {
    1: [0.0, 0.0, 0.0, 14.0],
    2: [0.0, 20.0, 0.0, 12.0],
    3: [26.0, 20.0, 0.0, 12.0],
    4: [32.0, 24.0, 16.0, 12.0],
    5: [40.0, 30.0, 20.0, 14.0],
    6: [48.0, 36.0, 26.0, 16.0],
    7: [58.0, 44.0, 32.0, 20.0],
  };

  static const buildingSpots = [
    Offset(-0.38, -0.38),
    Offset(0.08, -0.38),
    Offset(-0.38, 0.08),
    Offset(0.08, 0.08),
  ];

  static const buildingSize = 0.26;
  static const plateThickness = 12.0;

  late double _centerX;
  late double _centerY;
  late double _halfWidth;

  Offset _point(double u, double v, double height) {
    return Offset(
      _centerX + (u - v) * _halfWidth,
      _centerY + (u + v) * _halfWidth / 2 - height,
    );
  }

  void _drawFace(Canvas canvas, List<Offset> corners, Color color) {
    canvas.drawPath(Path()..addPolygon(corners, true), Paint()..color = color);
  }

  void _drawBlock(
    Canvas canvas, {
    required double u,
    required double v,
    required double size,
    required double bottom,
    required double top,
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
  }) {
    _drawFace(canvas, [
      _point(u, v + size, top),
      _point(u + size, v + size, top),
      _point(u + size, v + size, bottom),
      _point(u, v + size, bottom),
    ], leftColor);
    _drawFace(canvas, [
      _point(u + size, v, top),
      _point(u + size, v + size, top),
      _point(u + size, v + size, bottom),
      _point(u + size, v, bottom),
    ], rightColor);
    _drawFace(canvas, [
      _point(u, v, top),
      _point(u + size, v, top),
      _point(u + size, v + size, top),
      _point(u, v + size, top),
    ], topColor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _halfWidth = size.width * 0.45;
    _centerX = size.width / 2;
    _centerY = size.height - (_halfWidth / 2 + plateThickness + 10);

    final shadowCenter = Offset(
      _centerX,
      _centerY + _halfWidth / 2 + plateThickness - 2,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: _halfWidth * 2.1,
        height: _halfWidth * 0.7,
      ),
      Paint()..color = AppColors.islandGlow,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: _halfWidth * 1.5,
        height: _halfWidth * 0.3,
      ),
      Paint()..color = AppColors.islandShadow,
    );

    _drawBlock(
      canvas,
      u: -0.5,
      v: -0.5,
      size: 1,
      bottom: -plateThickness,
      top: 0,
      topColor: AppColors.islandTop,
      leftColor: AppColors.islandLeft,
      rightColor: AppColors.islandRight,
    );

    final heights = buildingHeightsByChapter[chapterNumber]!;
    for (var i = 0; i < buildingSpots.length; i++) {
      if (heights[i] == 0) continue;
      _drawBlock(
        canvas,
        u: buildingSpots[i].dx,
        v: buildingSpots[i].dy,
        size: buildingSize,
        bottom: 0,
        top: heights[i],
        topColor: AppColors.buildingTop,
        leftColor: AppColors.buildingLeft,
        rightColor: AppColors.buildingRight,
      );
    }
  }

  @override
  bool shouldRepaint(IslandPainter oldDelegate) =>
      oldDelegate.chapterNumber != chapterNumber;
}
