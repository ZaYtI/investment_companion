import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/simulate_level.dart';
import '../../../providers/simulation_providers.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import 'amount_card.dart';
import 'simulations_builder.dart';
import 'simulator_scaffold.dart';
import 'simulator_widgets.dart';

class SingleAssetSimulatorScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final SimulateLevel level;

  const SingleAssetSimulatorScreen({
    super.key,
    required this.chapterNumber,
    required this.level,
  });

  @override
  ConsumerState<SingleAssetSimulatorScreen> createState() =>
      _SingleAssetSimulatorScreenState();
}

class _SingleAssetSimulatorScreenState
    extends ConsumerState<SingleAssetSimulatorScreen> {
  static const virtualCapital = 10000;
  static const defaultAmount = 1000;

  late final List<String> _assets = (widget.level.settings['assets'] as List)
      .cast<String>();
  late final List<int> _periods =
      (widget.level.settings['periodsInYears'] as List).cast<int>();
  late final Map<String, dynamic> _amountSettings =
      widget.level.settings['amount'] as Map<String, dynamic>;

  late var _asset = _assets.first;
  late var _years = _periods.first;
  var _amount = defaultAmount;
  var _isAmountValid = true;

  @override
  Widget build(BuildContext context) {
    final series = ref.watch(priceSeriesProvider(_asset));
    final lastDate = series.value?.lastDate;
    return SimulatorScaffold(
      chapterNumber: widget.chapterNumber,
      title: 'Un actif, une période',
      level: widget.level,
      children: [
        OptionChips<String>(
          label: 'ACTIF',
          options: _assets,
          selected: _asset,
          labelOf: (asset) => assetLabels[asset]!,
          onSelected: (asset) => setState(() => _asset = asset),
        ),
        const SizedBox(height: 16),
        OptionChips<int>(
          label: 'DURÉE',
          options: _periods,
          selected: _years,
          labelOf: (years) => years == 1 ? '1 an' : '$years ans',
          onSelected: (years) => setState(() => _years = years),
        ),
        const SizedBox(height: 16),
        AmountCard(
          label: 'Montant investi',
          value: _amount,
          min: _amountSettings['min'] as int,
          max: virtualCapital,
          step: _amountSettings['step'] as int,
          onChanged: (amount) => setState(() => _amount = amount),
          onValidityChanged: (isValid) =>
              setState(() => _isAmountValid = isValid),
        ),
        const SizedBox(height: 20),
        if (!_isAmountValid)
          const InvalidAmountNotice(
            message:
                'Entrez un montant valide pour voir ce qu\'il serait devenu.',
          )
        else if (series.hasError)
          ErrorView(
            message: 'Impossible de charger les cours.',
            onRetry: () => ref.invalidate(priceSeriesProvider(_asset)),
          )
        else if (lastDate == null)
          const SkeletonBox(height: 260)
        else
          SimulationsBuilder(
            requests: [
              SimulationRequest(
                weights: {_asset: 1},
                start: DateTime(
                  lastDate.year - _years,
                  lastDate.month,
                  lastDate.day,
                ),
                amount: _amount.toDouble(),
              ),
            ],
            builder: (results) {
              final result = results.first;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResultHeader(
                    invested: _amount.toDouble(),
                    finalValue: result.finalValue,
                  ),
                  const SizedBox(height: 16),
                  ChartCard(
                    key: ValueKey('$_asset$_years'),
                    drawProgressively: true,
                    title: assetLabels[_asset]!,
                    trailing: _years == 1 ? '1 an' : '$_years ans',
                    lines: [
                      ChartLine(
                        isFilled: true,
                        points: chartPointsOf(result.dates, result.values),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
