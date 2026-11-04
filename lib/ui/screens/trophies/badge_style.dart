import 'package:flutter/material.dart';

import '../../../services/badges.dart';
import '../../theme/app_colors.dart';

Color badgeColorOf(BadgeStatus badge) {
  if (badge.isEarned) return AppColors.gold;
  if (badge.isStarted) return AppColors.assetEtf;
  return AppColors.dashedBorder;
}

IconData badgeIconOf(BadgeStatus badge) {
  if (badge.isEarned) return Icons.check_rounded;
  if (badge.isStarted) return Icons.circle;
  return Icons.lock_rounded;
}

String badgeStateOf(BadgeStatus badge) {
  if (badge.isEarned) return 'Obtenu';
  if (badge.isStarted) return 'En cours';
  return 'À débloquer';
}
