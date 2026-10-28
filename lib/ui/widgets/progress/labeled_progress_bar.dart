import 'package:flutter/material.dart';

import '../../format/app_format.dart';
import '../../theme/app_colors.dart';

class LabeledProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const LabeledProgressBar({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.mintChart,
  });

  static const barHeight = 8.0;
  static const labelSpacing = 6.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clampedValue = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Text(
              AppFormat.percent(clampedValue),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: labelSpacing),
        LinearProgressIndicator(
          value: clampedValue,
          color: color,
          minHeight: barHeight,
          borderRadius: BorderRadius.circular(barHeight),
        ),
      ],
    );
  }
}
