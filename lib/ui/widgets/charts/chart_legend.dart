import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../badges/app_badge.dart';
import 'price_chart.dart';

class ChartLegend extends StatelessWidget {
  final List<ChartLine> lines;

  const ChartLegend({super.key, required this.lines});

  static const swatchWidth = 16.0;
  static const swatchHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: [
        for (final line in lines)
          if (line.label != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: swatchWidth,
                  height: swatchHeight,
                  decoration: BoxDecoration(
                    color: line.color,
                    borderRadius: BorderRadius.circular(swatchHeight),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  line.label!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
      ],
    );
  }
}

class ChartMarkerList extends StatelessWidget {
  final List<ChartMarker> markers;

  const ChartMarkerList({super.key, required this.markers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final marker in markers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge.text(
                  '${marker.number}',
                  background: AppColors.gold,
                  foreground: AppColors.textPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    marker.label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
