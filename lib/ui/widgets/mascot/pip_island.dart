import 'package:flutter/material.dart';

import 'floating_pip.dart';

class PipIsland extends StatelessWidget {
  final double width;

  const PipIsland({super.key, this.width = originalWidth});

  static const originalWidth = 215.0;
  static const originalHeight = 214.0;
  static const originalIslandTop = 89.5;
  static const originalPipTop = 5.5;
  static const originalPipLeft = 77.0;
  static const originalPipWidth = 61.0;

  @override
  Widget build(BuildContext context) {
    final scale = width / originalWidth;
    return SizedBox(
      width: width,
      height: originalHeight * scale,
      child: Stack(
        children: [
          Positioned(
            top: originalIslandTop * scale,
            left: 0,
            child: Image.asset(
              'assets/images/welcome_island.png',
              width: width,
            ),
          ),
          Positioned(
            top: originalPipTop * scale,
            left: originalPipLeft * scale,
            child: FloatingPip(width: originalPipWidth * scale),
          ),
        ],
      ),
    );
  }
}
