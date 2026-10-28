import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_card.dart';

class StatTile extends StatelessWidget {
  final String label;
  final Widget value;

  const StatTile({super.key, required this.label, required this.value});

  static const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          value,
        ],
      ),
    );
  }
}
