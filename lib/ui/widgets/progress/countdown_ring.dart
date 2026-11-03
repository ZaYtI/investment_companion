import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'progress_ring.dart';

class CountdownRing extends StatefulWidget {
  final int seconds;
  final VoidCallback onTimeout;

  const CountdownRing({
    super.key,
    required this.seconds,
    required this.onTimeout,
  });

  @override
  State<CountdownRing> createState() => CountdownRingState();
}

class CountdownRingState extends State<CountdownRing>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const urgentSeconds = 5;
  static const ringSize = 64.0;

  late final AnimationController _controller;
  var _isStopped = false;

  double get elapsedSeconds => _controller.value * widget.seconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller =
        AnimationController(
            vsync: this,
            duration: Duration(seconds: widget.seconds),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onTimeout();
          })
          ..forward();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isStopped) return;
    if (state == AppLifecycleState.resumed) {
      _controller.forward();
    } else {
      _controller.stop();
    }
  }

  void stop() {
    _isStopped = true;
    _controller.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final secondsLeft = (widget.seconds - elapsedSeconds).ceil();
        final color = secondsLeft <= urgentSeconds
            ? AppColors.red
            : AppColors.goldChart;
        return Semantics(
          label: '$secondsLeft secondes restantes',
          child: ProgressRing(
            value: 1 - _controller.value,
            color: color,
            size: ringSize,
            strokeWidth: 6,
            child: Text(
              '$secondsLeft',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
