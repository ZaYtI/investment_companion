import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../badges/app_badge.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  static const retryLabel = 'Réessayer';
  static const spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBadge.icon(
          Icons.wifi_off,
          background: AppColors.coralPale,
          foreground: AppColors.redText,
        ),
        const SizedBox(height: spacing),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text(retryLabel)),
      ],
    );
  }
}
