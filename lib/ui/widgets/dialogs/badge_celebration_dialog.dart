import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../services/badges.dart';
import '../../theme/app_colors.dart';

const _animationPath = 'assets/animations/badge_unlocked.json';
const _animationSize = 180.0;

Future<void> showBadgeCelebration(
  BuildContext context,
  BadgeStatus badge, {
  required bool isAnimationEnabled,
}) {
  final shouldAnimate =
      isAnimationEnabled && !MediaQuery.disableAnimationsOf(context);
  return showDialog<void>(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: _animationSize,
              child: shouldAnimate
                  ? Lottie.asset(_animationPath, repeat: false)
                  : const Icon(
                      Icons.star_rounded,
                      size: _animationSize * 0.7,
                      color: AppColors.gold,
                    ),
            ),
            Text('NOUVEAU BADGE', style: textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              badge.condition,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Super'),
          ),
        ],
      );
    },
  );
}
