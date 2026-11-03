import 'package:flutter/material.dart';

import '../../../services/calc/invalid_input_exception.dart';
import '../../../services/simulation_service.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/text/change_text.dart';

const assetLabels = {
  'spy_weekly': 'ETF S&P 500',
  'spy_monthly': 'ETF S&P 500',
  'spy_daily_2020': 'ETF S&P 500',
  'gold_weekly': 'Or',
  'world_weekly': 'ETF MSCI World',
  'btc_weekly': 'Bitcoin',
  'qqq_weekly': 'Technologie',
  'bonds_weekly': 'Obligations',
  'cash': 'Liquidités',
};

const assetColors = {
  'spy_weekly': AppColors.assetStocks,
  'gold_weekly': AppColors.goldText,
  'world_weekly': AppColors.assetEtf,
  'btc_weekly': AppColors.assetCrypto,
  'qqq_weekly': AppColors.assetCurrenciesAndChallenges,
  'bonds_weekly': AppColors.assetBonds,
  'cash': AppColors.textSecondary,
};

String simulationErrorMessage(Object error) {
  return switch (error) {
    HistoryTooShortException(:final earliestDate) =>
      'Les cours commencent en ${AppFormat.monthYear(earliestDate)}. '
          'Choisissez une date plus récente.',
    InvalidInputException(:final message) => message,
    _ => 'Impossible de calculer la simulation.',
  };
}

class ResultHeader extends StatelessWidget {
  final double invested;
  final double finalValue;
  final String investedLabel;

  const ResultHeader({
    super.key,
    required this.invested,
    required this.finalValue,
    this.investedLabel = 'investis',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résultat de votre simulation',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          children: [
            ChangeText.percent(
              finalValue / invested - 1,
              style: textTheme.displaySmall,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ChangeText.euro(
                finalValue - invested,
                style: textTheme.titleLarge,
              ),
            ),
          ],
        ),
        Text(
          '${AppFormat.euro(invested)} $investedLabel deviennent '
          '${AppFormat.euro(finalValue)}',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.expand_more, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class OptionChips<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;

  const OptionChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == selected,
                onSelected: (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}

class StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
