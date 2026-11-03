import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class StepLabel extends StatelessWidget {
  final int step;

  const StepLabel({super.key, required this.step});

  static const stepCount = 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Text(
          'Étape $step sur $stepCount',
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
