import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/mascot/floating_pip.dart';

class PipSays extends StatelessWidget {
  final String text;

  const PipSays({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const FloatingPip(width: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mintPale,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.mintText),
            ),
          ),
        ),
      ],
    );
  }
}
