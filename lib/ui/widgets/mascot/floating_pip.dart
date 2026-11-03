import 'package:flutter/material.dart';

class FloatingPip extends StatefulWidget {
  final double width;

  const FloatingPip({super.key, this.width = 61});

  @override
  State<FloatingPip> createState() => _FloatingPipState();
}

class _FloatingPipState extends State<FloatingPip>
    with SingleTickerProviderStateMixin {
  static const floatDuration = Duration(milliseconds: 1600);
  static const floatHeight = 8.0;

  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: floatDuration);
    _offset = Tween<double>(
      begin: 0,
      end: -floatHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _offset.value), child: child),
      child: Image.asset('assets/images/pip.png', width: widget.width),
    );
  }
}
