import 'package:flutter/material.dart';

import '../../../models/simulate_level.dart';
import '../../../services/calc/goal.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import 'amount_card.dart';
import 'simulator_scaffold.dart';
import 'simulator_widgets.dart';

class GoalScenariosScreen extends StatefulWidget {
  final int chapterNumber;
  final SimulateLevel level;

  const GoalScenariosScreen({
    super.key,
    required this.chapterNumber,
    required this.level,
  });

  @override
  State<GoalScenariosScreen> createState() => _GoalScenariosScreenState();
}

class _GoalScenariosScreenState extends State<GoalScenariosScreen> {
  static const rateColors = [
    AppColors.assetBonds,
    AppColors.mintChart,
    AppColors.goldChart,
  ];

  late final _settings = widget.level.settings;
  late final List<double> _rates = (_settings['rates'] as List)
      .map((rate) => (rate as num).toDouble())
      .toList();
  late final _targetLimits = _settings['target'] as Map<String, dynamic>;
  late final _monthlyLimits = _settings['monthly'] as Map<String, dynamic>;
  late final _yearsLimits = _settings['years'] as Map<String, dynamic>;

  late var _target = _targetLimits['default'] as int;
  late var _monthly = _monthlyLimits['default'] as int;
  late var _years = _yearsLimits['default'] as int;
  var _showRequiredMonthly = false;
  final _invalidFields = <String>{};

  void _setFieldValidity(String field, bool isValid) {
    setState(() {
      if (isValid) {
        _invalidFields.remove(field);
      } else {
        _invalidFields.add(field);
      }
    });
  }

  int get _months => _years * monthsPerYear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final totalPaid = _monthly * _months.toDouble();
    final middleRate = _rates[_rates.length ~/ 2];
    final middleFinal = futureValue(_monthly.toDouble(), middleRate, _months);
    final today = DateTime.now();

    return SimulatorScaffold(
      chapterNumber: widget.chapterNumber,
      title: 'Atteindre un objectif',
      level: widget.level,
      children: [
        AmountCard(
          label: 'Objectif',
          value: _target,
          min: _targetLimits['min'] as int,
          max: _targetLimits['max'] as int,
          step: 1000,
          onChanged: (value) => setState(() => _target = value),
          onValidityChanged: (isValid) => _setFieldValidity('target', isValid),
        ),
        const SizedBox(height: 12),
        AmountCard(
          label: 'Versement mensuel',
          value: _monthly,
          min: _monthlyLimits['min'] as int,
          max: _monthlyLimits['max'] as int,
          step: 10,
          onChanged: (value) => setState(() => _monthly = value),
          onValidityChanged: (isValid) => _setFieldValidity('monthly', isValid),
        ),
        const SizedBox(height: 12),
        AmountCard(
          label: 'Durée',
          value: _years,
          min: _yearsLimits['min'] as int,
          max: _yearsLimits['max'] as int,
          step: 1,
          unit: 'ans',
          onChanged: (value) => setState(() => _years = value),
          onValidityChanged: (isValid) => _setFieldValidity('years', isValid),
        ),
        const SizedBox(height: 20),
        if (_invalidFields.isNotEmpty)
          const InvalidAmountNotice(
            message: 'Corrigez les valeurs en rouge pour voir les scénarios.',
          )
        else ...[
          if (isGoalTooEasy(_target.toDouble(), _monthly.toDouble()))
            Text(
              'Votre objectif est très facile à atteindre.',
              style: textTheme.titleMedium,
            ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${AppFormat.euro(totalPaid)} versés en $_years ans',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final (index, rate) in _rates.indexed)
                  _ScenarioRow(
                    rate: rate,
                    color: rateColors[index],
                    finalValue: futureValue(_monthly.toDouble(), rate, _months),
                    target: _target.toDouble(),
                    requiredMonthly: _showRequiredMonthly
                        ? requiredMonthly(_target.toDouble(), rate, _months)
                        : null,
                  ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => setState(
                    () => _showRequiredMonthly = !_showRequiredMonthly,
                  ),
                  child: Text(
                    _showRequiredMonthly
                        ? 'Masquer le versement nécessaire'
                        : 'Trouver le versement',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'À ${AppFormat.percent(middleRate)} par an, '
            '${AppFormat.percent(gainsShare(middleFinal, totalPaid))} '
            'du capital final vient des gains.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Capital au fil des années',
            target: _target.toDouble(),
            lines: [
              for (final (index, rate) in _rates.indexed)
                ChartLine(
                  label: AppFormat.percent(rate),
                  color: rateColors[index],
                  points: [
                    ChartPoint(today, 0),
                    for (var year = 1; year <= _years; year++)
                      ChartPoint(
                        DateTime(today.year + year, today.month),
                        futureValue(
                          _monthly.toDouble(),
                          rate,
                          year * monthsPerYear,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  final double rate;
  final Color color;
  final double finalValue;
  final double target;
  final double? requiredMonthly;

  const _ScenarioRow({
    required this.rate,
    required this.color,
    required this.finalValue,
    required this.target,
    required this.requiredMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isReached = finalValue >= target;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${AppFormat.percent(rate)} par an',
                style: textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                AppFormat.euro(finalValue),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            isReached
                ? 'Objectif atteint'
                : 'Il manque environ ${AppFormat.euro(target - finalValue)}',
            style: textTheme.bodyMedium?.copyWith(
              color: isReached ? AppColors.mintText : AppColors.redText,
            ),
          ),
          if (requiredMonthly != null)
            Text(
              'Versement nécessaire : '
              '${AppFormat.euro(requiredMonthly!)} par mois',
              style: textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}
