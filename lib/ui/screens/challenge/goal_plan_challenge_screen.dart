import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/challenge_level.dart';
import '../../../models/price_point.dart';
import '../../../providers/simulation_providers.dart';
import '../../../services/calc/dca.dart';
import '../../../services/calc/goal.dart';
import '../../format/app_format.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/states/error_view.dart';
import '../simulate/amount_card.dart';
import 'challenge_scaffold.dart';

class GoalPlanChallengeScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final ChallengeLevel challenge;

  const GoalPlanChallengeScreen({
    super.key,
    required this.chapterNumber,
    required this.challenge,
  });

  @override
  ConsumerState<GoalPlanChallengeScreen> createState() =>
      _GoalPlanChallengeScreenState();
}

class _GoalPlanChallengeScreenState
    extends ConsumerState<GoalPlanChallengeScreen> {
  static const stressTestSeries = 'spy_monthly';

  late final _data = widget.challenge.data;
  late final double _target = (_data['target'] as num).toDouble();
  late final double _rate = (_data['rate'] as num).toDouble();
  late final _monthlyLimits = _data['monthly'] as Map<String, dynamic>;
  late final _yearsLimits = _data['years'] as Map<String, dynamic>;
  late final DateTime _stressTestStart = DateTime.parse(
    '${_data['stressTestStart']}-01',
  );
  late final int _maxMonthlyForThreeStars =
      ((_data['stars'] as List).last as Map<String, dynamic>)['maxMonthly']
          as int;

  late var _monthly = _monthlyLimits['max'] as int;
  late var _years = _yearsLimits['min'] as int;
  ChallengeResult? _result;
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

  double get _finalAtRate =>
      futureValue(_monthly.toDouble(), _rate, _years * monthsPerYear);

  void _validate(List<PricePoint> prices) {
    final end = DateTime(
      _stressTestStart.year + _years,
      _stressTestStart.month,
    );
    final deposits = firstPriceOfEachMonth(
      prices,
      from: _stressTestStart,
      to: DateTime(end.year, end.month - 1),
    ).prices;
    final finalPrice = prices.firstWhere((point) => !point.date.isBefore(end));
    final stressTest = monthlyInvestment(
      deposits,
      amount: _monthly.toDouble(),
      finalPrice: finalPrice.close,
    );
    final worstRatio = stressTest.steps
        .map((step) => step.value / step.invested)
        .reduce((a, b) => a < b ? a : b);

    final reachedAtRate = _finalAtRate >= _target;
    final reachedInStressTest = stressTest.finalValue >= _target;
    final stars = reachedAtRate && reachedInStressTest
        ? (_monthly <= _maxMonthlyForThreeStars ? 3 : 2)
        : 1;

    setState(() {
      _result = ChallengeResult(
        stars: stars,
        title: reachedAtRate
            ? 'Objectif atteint à ${AppFormat.percent(_rate)}'
            : 'Vous arrivez à ${AppFormat.percent(_finalAtRate / _target)} '
                  'de l\'objectif',
        explanation:
            'À ${AppFormat.percent(_rate)} par an : '
            '${AppFormat.euro(_finalAtRate)}. '
            'Rejoué sur l\'ETF S&P 500 depuis janvier 2008 : '
            '${AppFormat.euro(stressTest.finalValue)}. '
            'Au pire moment, vos versements valaient '
            '${AppFormat.percent(1 - worstRatio)} de moins que ce que vous aviez versé.'
            '${reachedAtRate ? '' : ' Deux leviers : allonger la durée ou augmenter le versement.'}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final series = ref.watch(priceSeriesProvider(stressTestSeries));
    final prices = series.value?.points;
    return ChallengeScaffold(
      chapterNumber: widget.chapterNumber,
      situation: widget.challenge.situation,
      keyMessage: widget.challenge.keyMessage,
      result: _result,
      children: [
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
        const SizedBox(height: 16),
        if (_invalidFields.isNotEmpty)
          const InvalidAmountNotice(
            message: 'Corrigez les valeurs en rouge pour valider votre plan.',
          )
        else
          AppCard(
            child: Text(
              'À ${AppFormat.percent(_rate)} par an, vous auriez '
              '${AppFormat.euro(_finalAtRate)} pour un objectif de '
              '${AppFormat.euro(_target)}.',
              style: textTheme.titleMedium,
            ),
          ),
        const SizedBox(height: 20),
        if (series.hasError) ...[
          ErrorView(
            message: 'Impossible de charger les cours du test de résistance.',
            onRetry: () =>
                ref.invalidate(priceSeriesProvider(stressTestSeries)),
          ),
          const SizedBox(height: 12),
        ],
        PrimaryButton(
          text: 'Valider mon plan',
          onPressed: prices == null || _invalidFields.isNotEmpty
              ? null
              : () => _validate(prices),
        ),
      ],
    );
  }
}
