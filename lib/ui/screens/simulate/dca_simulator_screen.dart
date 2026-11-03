import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/dca_options.dart';
import '../../../models/simulate_level.dart';
import '../../../providers/dca_providers.dart';
import '../../../services/simulation_service.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import 'amount_card.dart';
import 'simulator_scaffold.dart';
import 'simulator_widgets.dart';

class DcaSimulatorScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final SimulateLevel level;

  const DcaSimulatorScreen({
    super.key,
    required this.chapterNumber,
    required this.level,
  });

  @override
  ConsumerState<DcaSimulatorScreen> createState() => _DcaSimulatorScreenState();
}

class _DcaSimulatorScreenState extends ConsumerState<DcaSimulatorScreen> {
  late final _options = DcaOptions.fromSettings(widget.level.settings);

  DcaSettingsNotifier get _settings =>
      ref.read(dcaSettingsProvider(_options).notifier);

  Future<void> _pickStart(DateTime current, DateTime lastDate) async {
    final months = <DateTime>[];
    var month = DateTime(lastDate.year, lastDate.month);
    while (!month.isBefore(_options.earliestStart)) {
      months.add(month);
      month = DateTime(month.year, month.month - 1);
    }
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => _MonthPicker(months: months, selected: current),
    );
    if (picked != null) _settings.setStart(picked);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(dcaSettingsProvider(_options));
    final simulation = ref.watch(dcaSimulationProvider(_options));
    final result = simulation.value;

    return SimulatorScaffold(
      chapterNumber: widget.chapterNumber,
      title: 'Simulateur DCA',
      level: widget.level,
      priceDate: result == null ? null : AppFormat.day(result.lastPrice.date),
      children: [
        if (simulation.hasError)
          ErrorView(message: simulationErrorMessage(simulation.error!))
        else if (result == null)
          const SkeletonBox(height: 90)
        else
          ResultHeader(
            invested: result.dca.invested,
            finalValue: result.dca.finalValue,
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: InfoTile(label: 'Actif', value: 'ETF S&P 500'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoTile(
                label: 'Depuis',
                value: AppFormat.monthYear(settings.start),
                onTap: result == null
                    ? null
                    : () => _pickStart(settings.start, result.lastPrice.date),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AmountCard(
          label: 'Versement mensuel',
          value: settings.monthlyAmount,
          min: _options.minMonthly,
          max: _options.maxMonthly,
          step: _options.stepMonthly,
          onChanged: _settings.setMonthlyAmount,
        ),
        const SizedBox(height: 16),
        if (result == null)
          const SkeletonBox(height: PriceChart.defaultHeight)
        else
          _ChartCard(
            simulation: result,
            compareWithLumpSum: settings.compareWithLumpSum,
            onCompareChanged: _settings.setCompareWithLumpSum,
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final DcaSimulation simulation;
  final bool compareWithLumpSum;
  final ValueChanged<bool> onCompareChanged;

  const _ChartCard({
    required this.simulation,
    required this.compareWithLumpSum,
    required this.onCompareChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final steps = simulation.dca.steps;
    final lastPrice = simulation.lastPrice;
    final lines = [
      ChartLine(
        label: 'Valeur',
        isFilled: true,
        points: [
          for (final step in steps) ChartPoint(step.date, step.value),
          ChartPoint(lastPrice.date, simulation.dca.finalValue),
        ],
      ),
      ChartLine(
        label: 'Investi',
        color: AppColors.goldChart,
        isDashed: true,
        points: [
          for (final step in steps) ChartPoint(step.date, step.invested),
          ChartPoint(lastPrice.date, simulation.dca.invested),
        ],
      ),
      if (compareWithLumpSum)
        ChartLine(
          label: 'Placement unique',
          color: AppColors.assetBonds,
          points: [
            for (final step in steps)
              ChartPoint(step.date, simulation.lumpSumShares * step.price),
            ChartPoint(lastPrice.date, simulation.lumpSumFinalValue),
          ],
        ),
    ];
    return ChartCard(
      title: 'Capital investi et valeur',
      trailing: '${steps.length} mois',
      lines: lines,
      footer: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          activeTrackColor: AppColors.mint,
          title: Text(
            'Comparer avec un placement unique',
            style: textTheme.bodyLarge,
          ),
          value: compareWithLumpSum,
          onChanged: onCompareChanged,
        ),
        if (compareWithLumpSum)
          Text(
            'Les mêmes ${AppFormat.euro(simulation.dca.invested)} placés '
            'd\'un coup en ${AppFormat.monthYear(steps.first.date)} '
            'vaudraient ${AppFormat.euro(simulation.lumpSumFinalValue)}.',
            style: textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final List<DateTime> months;
  final DateTime selected;

  const _MonthPicker({required this.months, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Premier versement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final month in months)
                  ListTile(
                    title: Text(AppFormat.monthYear(month)),
                    trailing: month == selected
                        ? const Icon(Icons.check, color: AppColors.mintText)
                        : null,
                    onTap: () => Navigator.of(context).pop(month),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
