import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';

class QueuedNotice extends StatelessWidget {
  final bool isCompact;

  const QueuedNotice({super.key, this.isCompact = false});

  static const message =
      'Limite de 8 demandes par minute atteinte. Ces cours sont ajoutés à la '
      "prochaine mise à jour et s'afficheront tout seuls d'ici une minute.";

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (isCompact) {
      return Text(
        'Ajouté à la prochaine mise à jour',
        style: textTheme.bodySmall?.copyWith(color: AppColors.goldText),
      );
    }
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.hourglass_top, color: AppColors.goldText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouté à la prochaine mise à jour',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
