import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../badges/app_badge.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView({super.key, required this.message, this.icon = Icons.inbox});

  static const spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBadge.icon(
          icon,
          background: AppColors.mintPale,
          foreground: AppColors.mintText,
        ),
        const SizedBox(height: spacing),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
