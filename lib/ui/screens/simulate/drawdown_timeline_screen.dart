import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/progress.dart';
import '../../../models/simulate_level.dart';
import '../../../models/simulation_result.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/simulation_providers.dart';
import '../../../services/calc/risk.dart';
import '../../format/app_format.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/text/change_text.dart';
import 'simulations_builder.dart';
import 'simulator_scaffold.dart';
import 'simulator_widgets.dart';

class DrawdownTimelineScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final SimulateLevel level;

  const DrawdownTimelineScreen({
    super.key,
    required this.chapterNumber,
    required this.level,
  });

  @override
  ConsumerState<DrawdownTimelineScreen> createState() =>
      _DrawdownTimelineScreenState();
}

class _DrawdownTimelineScreenState
    extends ConsumerState<DrawdownTimelineScreen> {
  late final _settings = widget.level.settings;
  late final List<Map<String, dynamic>> _entries =
      (_settings['entryDates'] as List).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _horizons =
      (_settings['horizons'] as List).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _markers =
      (_settings['markers'] as List).cast<Map<String, dynamic>>();
  late final double _capital = (_settings['capital'] as num).toDouble();

  late var _entry = _entries.first;
  int? _dayIndex;

  String get _horizonKey => Progress.horizonChoiceKey(widget.chapterNumber);

  void _selectHorizon(Map<String, dynamic> horizon) {
    ref
        .read(progressProvider.notifier)
        .saveChoice(_horizonKey, horizon['id'] as String);
  }

  @override
  Widget build(BuildContext context) {
    final savedHorizon = ref
        .watch(currentProgressProvider)
        .choices[_horizonKey];
    final horizon = _horizons.firstWhere(
      (horizon) => horizon['id'] == savedHorizon,
      orElse: () => _horizons.last,
    );
    return SimulatorScaffold(
      chapterNumber: widget.chapterNumber,
      title: 'Traverser 2007 à 2009',
      level: widget.level,
      children: [
        OptionChips<Map<String, dynamic>>(
          label: "DATE D'ENTRÉE",
          options: _entries,
          selected: _entry,
          labelOf: (entry) => entry['label'] as String,
          onSelected: (entry) => setState(() {
            _entry = entry;
            _dayIndex = null;
          }),
        ),
        const SizedBox(height: 16),
        OptionChips<Map<String, dynamic>>(
          label: 'VOTRE HORIZON (IL SERT AU DÉFI)',
          options: _horizons,
          selected: horizon,
          labelOf: (horizon) => horizon['label'] as String,
          onSelected: _selectHorizon,
        ),
        const SizedBox(height: 20),
        SimulationsBuilder(
          requests: [
            SimulationRequest(
              weights: {_settings['asset'] as String: 1},
              start: DateTime.parse(_entry['date'] as String),
              end: DateTime.parse(_settings['end'] as String),
              amount: _capital,
            ),
          ],
          builder: (results) => _buildTimeline(results.first),
        ),
      ],
    );
  }

  Widget _buildTimeline(SimulationResult result) {
    final values = result.values;
    final dates = result.dates;
    final dayIndex = (_dayIndex ?? 0).clamp(0, values.length - 1);
    final value = values[dayIndex];
    final peakSoFar = values
        .sublist(0, dayIndex + 1)
        .reduce((a, b) => a > b ? a : b);
    final drawdown = maxDrawdown(values);
    final trough = values[drawdown.troughIndex];
    final recoveryIndex = values.indexWhere(
      (value) => value >= _capital,
      drawdown.troughIndex,
    );
    final descentMonths =
        (dates[drawdown.troughIndex]
                    .difference(dates[drawdown.peakIndex])
                    .inDays /
                30.4)
            .round();
    final markers = [
      for (final (index, marker) in _markers.indexed)
        ChartMarker(
          DateTime.parse(marker['date'] as String),
          index + 1,
          label: marker['label'] as String,
        ),
    ].where((marker) => !marker.date.isBefore(dates.first)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChartCard(
          title: 'Valeur de vos ${AppFormat.euro(_capital)}',
          lines: [
            ChartLine(isFilled: true, points: chartPointsOf(dates, values)),
          ],
          markers: markers,
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppFormat.day(dates[dayIndex]),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: dayIndex.toDouble(),
                max: (values.length - 1).toDouble(),
                onChanged: (index) => setState(() => _dayIndex = index.round()),
              ),
              StatRow(label: 'Valeur', value: AppFormat.euro(value)),
              StatRow(
                label: 'Baisse depuis le plus haut',
                value: AppFormat.percent(value / peakSoFar - 1),
                valueColor: ChangeText.colorFor(value / peakSoFar - 1),
              ),
              StatRow(
                label:
                    'Gain nécessaire pour revenir à '
                    '${AppFormat.euro(_capital)}',
                value: value >= _capital
                    ? 'Aucun'
                    : AppFormat.signedPercent(_capital / value - 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatRow(label: 'Valeur au creux', value: AppFormat.euro(trough)),
              StatRow(
                label: 'Pire baisse',
                value: AppFormat.percent(drawdown.percent),
                valueColor: ChangeText.colorFor(drawdown.percent),
              ),
              StatRow(
                label: 'Durée de la descente',
                value: '$descentMonths mois',
              ),
              StatRow(
                label: 'Gain nécessaire au creux',
                value: AppFormat.signedPercent(requiredGain(drawdown.percent)),
              ),
              StatRow(
                label: "Retour au niveau d'entrée",
                value: recoveryIndex == -1
                    ? 'Pas avant fin 2013'
                    : AppFormat.monthYear(dates[recoveryIndex]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
