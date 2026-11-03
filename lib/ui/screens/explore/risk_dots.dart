import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class RiskDots extends StatelessWidget {
  final int risk;
  final bool showLabel;

  const RiskDots({super.key, required this.risk, this.showLabel = true});

  static const maxRisk = 5;
  static const dotSize = 10.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Risque $risk sur $maxRisk',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var level = 1; level <= maxRisk; level++)
            Container(
              width: dotSize,
              height: dotSize,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: level <= risk
                    ? AppColors.textPrimary
                    : AppColors.dashedBorder,
              ),
            ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              'risque',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

const categoryColors = {
  'stocks': AppColors.assetStocks,
  'etf': AppColors.assetEtf,
  'bonds': AppColors.assetBonds,
  'crypto': AppColors.assetCrypto,
  'commodities': AppColors.goldChart,
  'currencies': AppColors.assetCurrenciesAndChallenges,
};
