import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class NightSky extends StatelessWidget {
  final bool showClouds;

  const NightSky({super.key, this.showClouds = true});

  static const starPositions = [
    Alignment(-0.85, -0.83),
    Alignment(0.79, -0.74),
    Alignment(-0.54, -0.58),
    Alignment(0.64, -0.5),
    Alignment(-0.8, -0.29),
    Alignment(0.84, -0.22),
    Alignment(-0.1, -0.05),
    Alignment(0.9, 0.1),
    Alignment(-0.9, 0.22),
    Alignment(0.35, 0.36),
    Alignment(-0.45, 0.55),
    Alignment(0.8, 0.68),
    Alignment(-0.75, 0.86),
    Alignment(0.2, 0.92),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showClouds) ...[
          const Align(
            alignment: Alignment(-0.64, -0.69),
            child: _Cloud(width: 110, height: 28),
          ),
          const Align(
            alignment: Alignment(0.69, -0.38),
            child: _Cloud(width: 95, height: 25),
          ),
        ],
        for (final position in starPositions)
          Align(alignment: position, child: const _Star()),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star();

  static const size = 3.0;
  static const opacity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double height;

  const _Cloud({required this.width, required this.height});

  static const opacity = 0.07;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: opacity),
        borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
      ),
    );
  }
}
