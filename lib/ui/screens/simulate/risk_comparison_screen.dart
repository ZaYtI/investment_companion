import 'package:flutter/material.dart';

import '../../../models/simulate_level.dart';
import '../../../models/simulation_result.dart';
import '../../../providers/simulation_providers.dart';
import '../../format/app_format.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/text/change_text.dart';
import 'simulations_builder.dart';
import 'simulator_scaffold.dart';
import 'simulator_widgets.dart';

class RiskComparisonScreen extends StatefulWidget {
  final int chapterNumber;
  final SimulateLevel level;

  const RiskComparisonScreen({
    super.key,
    required this.chapterNumber,
    required this.level,
  });

  @override
  State<RiskComparisonScreen> createState() => _RiskComparisonScreenState();
}

class _RiskComparisonScreenState extends State<RiskComparisonScreen> {
  late final List<String> _assets = (widget.level.settings['assets'] as List)
      .cast<String>();
  late final List<int> _startYears =
      (widget.level.settings['startYears'] as List).cast<int>();
  late final double _amount = (widget.level.settings['amountPerAsset'] as num)
      .toDouble();

  late var _startYear = _startYears.first;

  @override
  Widget build(BuildContext context) {
    return SimulatorScaffold(
      chapterNumber: widget.chapterNumber,
      title: 'Trois actifs, un départ',
      level: widget.level,
      children: [
        OptionChips<int>(
          label: 'DATE DE DÉPART',
          options: _startYears,
          selected: _startYear,
          labelOf: (year) => 'Janvier $year',
          onSelected: (year) => setState(() => _startYear = year),
        ),
        const SizedBox(height: 8),
        Text(
          '${AppFormat.euro(_amount)} placés dans chaque actif.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        SimulationsBuilder(
          requests: [
            for (final asset in _assets)
              SimulationRequest(
                weights: {asset: 1},
                start: DateTime(_startYear),
                amount: _amount,
              ),
          ],
          builder: (results) => Column(
            children: [
              for (var i = 0; i < _assets.length; i++) ...[
                _AssetResultCard(asset: _assets[i], result: results[i]),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AssetResultCard extends StatelessWidget {
  final String asset;
  final SimulationResult result;

  const _AssetResultCard({required this.asset, required this.result});

  static const chartHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final volatility = result.volatility;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assetLabels[asset]!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ChangeText.percent(result.performance),
            ],
          ),
          const SizedBox(height: 8),
          PriceChart(
            height: chartHeight,
            showDates: false,
            lines: [
              ChartLine(
                color: assetColors[asset]!,
                points: chartPointsOf(result.dates, result.values),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatRow(
            label: 'Valeur finale',
            value: AppFormat.euro(result.finalValue),
          ),
          StatRow(
            label: 'Volatilité annuelle',
            value: volatility == null ? '—' : AppFormat.percent(volatility),
          ),
          StatRow(
            label: 'Pire baisse',
            value: AppFormat.percent(result.maxDrawdown),
            valueColor: ChangeText.colorFor(result.maxDrawdown),
          ),
        ],
      ),
    );
  }
}
