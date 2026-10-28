import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';

class ChartPoint {
  const ChartPoint(this.date, this.value);

  final DateTime date;
  final double value;
}

class ChartLine {
  const ChartLine({
    required this.points,
    this.color = AppColors.mintChart,
    this.isFilled = false,
    this.isDashed = false,
  });

  final List<ChartPoint> points;
  final Color color;
  final bool isFilled;
  final bool isDashed;
}

class ChartMarker {
  const ChartMarker(this.date, this.number);

  final DateTime date;
  final int number;
}

class PriceChart extends StatelessWidget {
  final List<ChartLine> lines;
  final List<ChartMarker> markers;
  final double? target;
  final double height;
  final String Function(double value) formatValue;

  const PriceChart({
    super.key,
    required this.lines,
    this.markers = const [],
    this.target,
    this.height = defaultHeight,
    this.formatValue = _formatEuro,
  });

  static const defaultHeight = 200.0;
  static const lineWidth = 3.0;
  static const fillOpacity = 0.15;
  static const dashPattern = [6, 4];
  static const verticalPaddingRatio = 0.08;
  static const millisecondsPerDay = 86400000;

  static String _formatEuro(double value) => AppFormat.euro(value);

  static double _x(DateTime date) =>
      date.millisecondsSinceEpoch / millisecondsPerDay;

  static DateTime _date(double x) =>
      DateTime.fromMillisecondsSinceEpoch((x * millisecondsPerDay).round());

  @override
  Widget build(BuildContext context) {
    final values = [
      for (final line in lines)
        for (final point in line.points) point.value,
      ?target,
    ];
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxValue - minValue) * verticalPaddingRatio;
    final markerXs = {
      for (final marker in markers)
        if (lines.isNotEmpty && lines.first.points.isNotEmpty)
          _x(_pointOnOrAfter(lines.first.points, marker.date).date):
              marker.number,
    };

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minValue - padding,
          maxY: maxValue + padding,
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (target != null)
                HorizontalLine(
                  y: target!,
                  color: AppColors.textSecondary,
                  dashArray: dashPattern,
                ),
            ],
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.mapNight,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    '${DateFormat('dd/MM/yyyy').format(_date(spot.x))}\n'
                    '${formatValue(spot.y)}',
                    const TextStyle(
                      color: AppColors.surface,
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            for (final (index, line) in lines.indexed)
              LineChartBarData(
                spots: [
                  for (final point in line.points)
                    FlSpot(_x(point.date), point.value),
                ],
                color: line.color,
                barWidth: lineWidth,
                isCurved: true,
                preventCurveOverShooting: true,
                dashArray: line.isDashed ? dashPattern : null,
                belowBarData: BarAreaData(
                  show: line.isFilled,
                  color: line.color.withValues(alpha: fillOpacity),
                ),
                dotData: FlDotData(
                  show: index == 0 && markerXs.isNotEmpty,
                  checkToShowDot: (spot, _) => markerXs.containsKey(spot.x),
                  getDotPainter: (spot, _, _, _) =>
                      _NumberedDotPainter(markerXs[spot.x] ?? 0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static ChartPoint _pointOnOrAfter(List<ChartPoint> points, DateTime date) =>
      points.firstWhere(
        (p) => !p.date.isBefore(date),
        orElse: () => points.last,
      );
}

class _NumberedDotPainter extends FlDotPainter {
  const _NumberedDotPainter(this.number);

  final int number;

  static const radius = 11.0;
  static const strokeWidth = 2.0;
  static const fontSize = 12.0;

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    canvas
      ..drawCircle(offsetInCanvas, radius, Paint()..color = AppColors.gold)
      ..drawCircle(
        offsetInCanvas,
        radius,
        Paint()
          ..color = AppColors.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    final label = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: AppFonts.body,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
      canvas,
      offsetInCanvas - Offset(label.width / 2, label.height / 2),
    );
  }

  @override
  Size getSize(FlSpot spot) => const Size.fromRadius(radius + strokeWidth);

  @override
  Color get mainColor => AppColors.gold;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) => b;

  @override
  List<Object?> get props => [number];
}
