import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/dca_options.dart';
import '../../../models/level_type.dart';
import '../../../models/simulate_level.dart';
import '../../../providers/dca_providers.dart';
import '../../../services/calc/invalid_input_exception.dart';
import '../../../services/simulation_service.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/chart_legend.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import '../../widgets/text/change_text.dart';
import 'reading_question_card.dart';

class DcaSimulatorScreen extends ConsumerStatefulWidget {
  final SimulateLevel level;

  const DcaSimulatorScreen({super.key, required this.level});

  @override
  ConsumerState<DcaSimulatorScreen> createState() => _DcaSimulatorScreenState();
}

class _DcaSimulatorScreenState extends ConsumerState<DcaSimulatorScreen> {
  late final _options = DcaOptions.fromSettings(widget.level.settings);
  late final _amountController = TextEditingController(
    text: '${_options.defaultMonthly}',
  );
  final _formKey = GlobalKey<FormState>();
  var _hasAnsweredQuestion = false;

  DcaSettingsNotifier get _settings =>
      ref.read(dcaSettingsProvider(_options).notifier);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    final amount = value.round();
    _amountController.text = '$amount';
    _formKey.currentState?.validate();
    _settings.setMonthlyAmount(amount);
  }

  void _onAmountTyped(String text) {
    setState(() {});
    if (_options.validateMonthly(text) == null) {
      _settings.setMonthlyAmount(int.parse(text.trim()));
    }
  }

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

  void _finish() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Niveau terminé · +${LevelType.simulate.xp} XP')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(dcaSettingsProvider(_options));
    final simulation = ref.watch(dcaSimulationProvider(_options));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Simulateur DCA')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Text(
                    widget.level.instruction,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(simulation),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: _InfoTile(label: 'Actif', value: 'ETF S&P 500'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          label: 'Depuis',
                          value: AppFormat.monthYear(settings.start),
                          onTap: simulation.value == null
                              ? null
                              : () => _pickStart(
                                  settings.start,
                                  simulation.value!.lastPrice.date,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAmountCard(settings),
                  const SizedBox(height: 16),
                  if (simulation.value == null)
                    const SkeletonBox(height: PriceChart.defaultHeight)
                  else
                    _ChartCard(
                      simulation: simulation.value!,
                      compareWithLumpSum: settings.compareWithLumpSum,
                      onCompareChanged: _settings.setCompareWithLumpSum,
                    ),
                  const SizedBox(height: 28),
                  ReadingQuestionCard(
                    question: widget.level.readingQuestion,
                    onAnswered: () =>
                        setState(() => _hasAnsweredQuestion = true),
                  ),
                  const SizedBox(height: 24),
                  for (final note in widget.level.notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        note,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: Column(
                children: [
                  if (simulation.value != null)
                    Text(
                      'Cours du ${AppFormat.day(simulation.value!.lastPrice.date)}'
                      ' · Simulation pédagogique, pas un conseil financier.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    text: 'Terminer le niveau · +${LevelType.simulate.xp} XP',
                    onPressed: _hasAnsweredQuestion ? _finish : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<DcaSimulation> simulation) {
    final result = simulation.value;
    if (simulation.hasError) {
      return _buildError(simulation.error!);
    }
    if (result == null) {
      return const SkeletonBox(height: 90);
    }
    return _ResultHeader(simulation: result);
  }

  Widget _buildError(Object error) {
    final message = switch (error) {
      HistoryTooShortException(:final earliestDate) =>
        'Les cours commencent en ${AppFormat.monthYear(earliestDate)}. '
            'Choisissez une date plus récente.',
      InvalidInputException() =>
        'Il faut au moins 3 versements. Reculez la date de début.',
      _ => 'Impossible de calculer la simulation.',
    };
    return ErrorView(message: message);
  }

  Widget _buildAmountCard(DcaSettings settings) {
    final textTheme = Theme.of(context).textTheme;
    final sliderValue = settings.monthlyAmount
        .clamp(_options.minMonthly, _options.maxMonthly)
        .toDouble();
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Versement mensuel',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      suffixText: '€',
                      border: InputBorder.none,
                      isDense: true,
                      errorStyle: TextStyle(fontSize: 0, height: 0),
                    ),
                    validator: _options.validateMonthly,
                    onChanged: _onAmountTyped,
                  ),
                ),
              ],
            ),
            _amountErrorText(),
            Slider(
              value: sliderValue,
              min: _options.minMonthly.toDouble(),
              max: _options.maxMonthly.toDouble(),
              divisions:
                  (_options.maxMonthly - _options.minMonthly) ~/
                  _options.stepMonthly,
              label: AppFormat.euro(sliderValue),
              onChanged: _onSliderChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountErrorText() {
    final error = _options.validateMonthly(_amountController.text);
    if (error == null) return const SizedBox.shrink();
    return Text(
      error,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: AppColors.redText),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final DcaSimulation simulation;

  const _ResultHeader({required this.simulation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dca = simulation.dca;
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
            ChangeText.percent(dca.performance, style: textTheme.displaySmall),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ChangeText.euro(dca.gain, style: textTheme.titleLarge),
            ),
          ],
        ),
        Text(
          '${AppFormat.euro(dca.invested)} investis deviennent '
          '${AppFormat.euro(dca.finalValue)}',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({required this.label, required this.value, this.onTap});

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
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Capital investi et valeur',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${steps.length} mois',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PriceChart(lines: lines),
          const SizedBox(height: 12),
          ChartLegend(lines: lines),
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
      ),
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
