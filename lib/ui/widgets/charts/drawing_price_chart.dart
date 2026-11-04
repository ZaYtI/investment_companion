import 'package:flutter/material.dart';

import 'price_chart.dart';

class DrawingPriceChart extends StatefulWidget {
  final List<ChartLine> lines;
  final List<ChartMarker> markers;
  final double? target;
  final double height;
  final bool showDates;

  const DrawingPriceChart({
    super.key,
    required this.lines,
    this.markers = const [],
    this.target,
    this.height = PriceChart.defaultHeight,
    this.showDates = true,
  });

  @override
  State<DrawingPriceChart> createState() => _DrawingPriceChartState();
}

class _DrawingPriceChartState extends State<DrawingPriceChart>
    with SingleTickerProviderStateMixin {
  static const drawDuration = Duration(milliseconds: 1400);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: drawDuration,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = !MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => PriceChart(
        lines: widget.lines,
        markers: widget.markers,
        target: widget.target,
        height: widget.height,
        showDates: widget.showDates,
        visibleFraction: shouldAnimate ? _progress.value : 1,
      ),
    );
  }
}
