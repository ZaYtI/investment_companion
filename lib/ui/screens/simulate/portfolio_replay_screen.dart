import 'package:flutter/material.dart';

import '../../../models/simulate_level.dart';
import '../../../models/simulation_result.dart';
import '../../../providers/simulation_providers.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/text/change_text.dart';
import 'simulations_builder.dart';
import 'simulator_scaffold.dart';
import 'simulator_widgets.dart';
import 'weights_editor.dart';

class PortfolioReplayScreen extends StatefulWidget {
  final int chapterNumber;
  final SimulateLevel level;

  const PortfolioReplayScreen({
    super.key,
    required this.chapterNumber,
    required this.level,
  });

  @override
  State<PortfolioReplayScreen> createState() => _PortfolioReplayScreenState();
}

class _PortfolioReplayScreenState extends State<PortfolioReplayScreen> {
  static const portfolioColors = [
    AppColors.assetCurrenciesAndChallenges,
    AppColors.assetStocks,
    AppColors.mintChart,
    AppColors.assetBonds,
  ];

  late final _settings = widget.level.settings;
  late final List<Map<String, dynamic>> _entries =
      (_settings['entryDates'] as List).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _presets =
      (_settings['presets'] as List).cast<Map<String, dynamic>>();
  late final Map<String, String> _assetLabels = {
    for (final asset
        in (_settings['assets'] as List).cast<Map<String, dynamic>>())
      asset['id'] as String: asset['label'] as String,
  };
  late final double _capital = (_settings['capital'] as num).toDouble();

  late var _entry = _entries.first;
  late var _myPercents = {for (final asset in _assetLabels.keys) asset: 0};

  bool get _isMyPortfolioComplete => totalPercent(_myPercents) == 100;

  SimulationRequest _requestFor(Map<String, double> weights) {
    return SimulationRequest(
      weights: weights,
      start: DateTime.parse(_entry['date'] as String),
      end: DateTime.parse(_settings['end'] as String),
      amount: _capital,
    );
  }

  @override
  Widget build(BuildContext context) {
    final names = [
      for (final preset in _presets) preset['label'] as String,
      if (_isMyPortfolioComplete) 'Mon portefeuille',
    ];
    final requests = [
      for (final preset in _presets)
        _requestFor(
          (preset['weights'] as Map).map(
            (asset, weight) =>
                MapEntry(asset as String, (weight as num).toDouble()),
          ),
        ),
      if (_isMyPortfolioComplete) _requestFor(weightsFromPercents(_myPercents)),
    ];
    return SimulatorScaffold(
      chapterNumber: widget.chapterNumber,
      title: 'Face à la bulle internet',
      level: widget.level,
      children: [
        OptionChips<Map<String, dynamic>>(
          label: "DATE D'ENTRÉE",
          options: _entries,
          selected: _entry,
          labelOf: (entry) => entry['label'] as String,
          onSelected: (entry) => setState(() => _entry = entry),
        ),
        const SizedBox(height: 16),
        Text(
          'MON PORTEFEUILLE',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        WeightsEditor(
          assetLabels: _assetLabels,
          percents: _myPercents,
          onChanged: (percents) => setState(() => _myPercents = percents),
        ),
        const SizedBox(height: 20),
        SimulationsBuilder(
          requests: requests,
          builder: (results) => _buildResults(names, results),
        ),
      ],
    );
  }

  Widget _buildResults(List<String> names, List<SimulationResult> results) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChartCard(
          title: 'Valeur de ${AppFormat.euro(_capital)}',
          lines: [
            for (var i = 0; i < results.length; i++)
              ChartLine(
                label: names[i].split(' · ').first,
                color: portfolioColors[i],
                points: chartPointsOf(results[i].dates, results[i].values),
              ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < results.length; i++) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  names[i],
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: portfolioColors[i],
                  ),
                ),
                StatRow(
                  label: 'Valeur au creux',
                  value: AppFormat.euro(
                    results[i].values.reduce((a, b) => a < b ? a : b),
                  ),
                ),
                StatRow(
                  label: 'Pire baisse',
                  value: AppFormat.percent(results[i].maxDrawdown),
                  valueColor: ChangeText.colorFor(results[i].maxDrawdown),
                ),
                StatRow(
                  label: 'Valeur finale',
                  value: AppFormat.euro(results[i].finalValue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
