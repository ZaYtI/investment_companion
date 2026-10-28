import 'package:flutter/material.dart';

import '../../format/app_format.dart';
import '../../theme/app_colors.dart';

enum ChangeUnit { percent, euro }

class ChangeText extends StatelessWidget {
  final double value;
  final ChangeUnit unit;
  final TextStyle? style;

  const ChangeText.percent(this.value, {super.key, this.style})
    : unit = ChangeUnit.percent;

  const ChangeText.euro(this.value, {super.key, this.style})
    : unit = ChangeUnit.euro;

  static Color colorFor(double value) => switch (value) {
    > 0 => AppColors.mintText,
    < 0 => AppColors.redText,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final text = switch (unit) {
      ChangeUnit.percent => AppFormat.signedPercent(value),
      ChangeUnit.euro => AppFormat.signedEuro(value),
    };
    final baseStyle = style ?? Theme.of(context).textTheme.titleMedium;
    return Text(
      text,
      style: baseStyle?.copyWith(
        color: colorFor(value),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
