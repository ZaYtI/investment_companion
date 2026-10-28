import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;

  const SkeletonBox({super.key, required this.height, this.width});

  static const radius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
