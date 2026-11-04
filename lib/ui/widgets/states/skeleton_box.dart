import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SkeletonBox extends StatefulWidget {
  final double height;
  final double? width;

  const SkeletonBox({super.key, required this.height, this.width});

  static const radius = 12.0;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  static const pulseDuration = Duration(milliseconds: 800);

  late final _controller = AnimationController(
    vsync: this,
    duration: pulseDuration,
  )..repeat(reverse: true);

  late final _opacity = Tween<double>(begin: 1, end: 0.5).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(SkeletonBox.radius),
        ),
      ),
    );
  }
}
