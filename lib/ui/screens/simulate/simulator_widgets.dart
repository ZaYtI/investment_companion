import 'package:flutter/material.dart';

import '../../../services/calc/invalid_input_exception.dart';
import '../../../services/simulation_service.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/chart_legend.dart';
import '../../widgets/charts/drawing_price_chart.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/text/animated_gain_counter.dart';

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
            AnimatedGainCounter.percent(
              finalValue / invested - 1,
              style: textTheme.displaySmall,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: AnimatedGainCounter.euro(
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

class ChartCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final List<ChartLine> lines;
  final List<ChartMarker> markers;
  final double? target;
  final bool drawProgressively;
  final List<Widget> footer;

  const ChartCard({
    super.key,
    required this.title,
    required this.lines,
    this.trailing,
    this.markers = const [],
    this.target,
    this.drawProgressively = false,
    this.footer = const [],
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasLegend = lines.where((line) => line.label != null).length > 1;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (drawProgressively)
            DrawingPriceChart(lines: lines, markers: markers, target: target)
          else
            PriceChart(lines: lines, markers: markers, target: target),
          if (hasLegend) ...[
            const SizedBox(height: 12),
            ChartLegend(lines: lines),
          ],
          if (markers.isNotEmpty) ...[
            const SizedBox(height: 12),
            ChartMarkerList(markers: markers),
          ],
          ...footer,
        ],
      ),
    );
  }
}

List<ChartPoint> chartPointsOf(List<DateTime> dates, List<double> values) {
  return [
    for (var i = 0; i < dates.length; i++) ChartPoint(dates[i], values[i]),
  ];
}
