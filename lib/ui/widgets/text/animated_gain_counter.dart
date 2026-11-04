import 'package:flutter/material.dart';

import '../../format/app_format.dart';
import 'change_text.dart';

class AnimatedGainCounter extends StatefulWidget {
  final double value;
  final ChangeUnit unit;
  final TextStyle? style;

  const AnimatedGainCounter.percent(this.value, {super.key, this.style})
    : unit = ChangeUnit.percent;

  const AnimatedGainCounter.euro(this.value, {super.key, this.style})
    : unit = ChangeUnit.euro;

  @override
  State<AnimatedGainCounter> createState() => _AnimatedGainCounterState();
}

class _AnimatedGainCounterState extends State<AnimatedGainCounter>
    with SingleTickerProviderStateMixin {
  static const countDuration = Duration(milliseconds: 1200);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: countDuration,
  );
  late Animation<double> _count;

  @override
  void initState() {
    super.initState();
    _countBetween(0, widget.value);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedGainCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _countBetween(_count.value, widget.value);
      _controller.forward(from: 0);
    }
  }

  void _countBetween(double begin, double end) {
    _count = Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) => switch (widget.unit) {
    ChangeUnit.percent => AppFormat.signedPercent(value),
    ChangeUnit.euro => AppFormat.signedEuro(value),
  };

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? Theme.of(context).textTheme.titleMedium;
    final style = baseStyle?.copyWith(
      color: ChangeText.colorFor(widget.value),
      fontWeight: FontWeight.w700,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(_format(widget.value), style: style);
    }
    return AnimatedBuilder(
      animation: _count,
      builder: (context, _) => Text(_format(_count.value), style: style),
    );
  }
}
