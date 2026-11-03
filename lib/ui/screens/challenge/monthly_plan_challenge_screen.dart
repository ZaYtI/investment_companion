import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/challenge_level.dart';
import '../../../models/price_point.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/simulation_providers.dart';
import '../../../services/calc/scoring.dart';
import '../../format/app_format.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/selectable_card.dart';
import '../../widgets/states/skeleton_box.dart';
import '../../widgets/text/change_text.dart';
import 'challenge_scaffold.dart';

class MonthlyPlanChallengeScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final ChallengeLevel challenge;

  const MonthlyPlanChallengeScreen({
    super.key,
    required this.chapterNumber,
    required this.challenge,
  });

  @override
  ConsumerState<MonthlyPlanChallengeScreen> createState() =>
      _MonthlyPlanChallengeScreenState();
}

class _MonthlyPlanChallengeScreenState
    extends ConsumerState<MonthlyPlanChallengeScreen> {
  static const pricesId = 'spy_monthly';
  static const planStart = 2022;

  late final _data = widget.challenge.data;
  late final double _monthlyAmount = (_data['monthlyAmount'] as num).toDouble();
  late final List<DateTime> _months = (_data['months'] as List)
      .map((month) => DateTime.parse('$month-01'))
      .toList();
  late final List<Map<String, dynamic>> _decisionOptions =
      (_data['decisions'] as List).cast<Map<String, dynamic>>();

  final _decisions = <MonthlyDecision>[];
  final _multipliers = <int>[];
  ChallengeResult? _result;

  PricePoint _firstPriceOf(List<PricePoint> prices, DateTime month) {
    return prices.firstWhere(
      (point) =>
          point.date.year == month.year && point.date.month == month.month,
    );
  }

  double _monthChange(List<PricePoint> prices, DateTime month) {
    final nextMonth = DateTime(month.year, month.month + 1);
    return _firstPriceOf(prices, nextMonth).close /
            _firstPriceOf(prices, month).close -
        1;
  }

  ({double invested, double value}) _planValue(
    List<PricePoint> prices,
    List<int> multipliers,
  ) {
    final endMonth = DateTime(_months.last.year, _months.last.month + 1);
    var invested = 0.0;
    var shares = 0.0;
    var month = DateTime(planStart);
    var index = 0;
    while (month.isBefore(endMonth)) {
      final isChallengeMonth = _months.contains(month);
      final multiplier = isChallengeMonth ? multipliers[index++] : 1;
      final amount = _monthlyAmount * multiplier;
      invested += amount;
      shares += amount / _firstPriceOf(prices, month).close;
      month = DateTime(month.year, month.month + 1);
    }
    return (
      invested: invested,
      value: shares * _firstPriceOf(prices, endMonth).close,
    );
  }

  void _decide(List<PricePoint> prices, Map<String, dynamic> option) {
    _decisions.add(MonthlyDecision.values.byName(option['id'] as String));
    _multipliers.add(option['multiplier'] as int);
    if (_decisions.length < _months.length) {
      setState(() {});
      return;
    }
    final changes = [for (final month in _months) _monthChange(prices, month)];
    final measures = monthlyPlanMeasures(_decisions, changes);
    ref
        .read(progressProvider.notifier)
        .recordChallengeChoice(wasPatient: measures.coherence == 100);
    final mine = _planValue(prices, _multipliers);
    final perfect = _planValue(prices, List.filled(_months.length, 1));
    setState(() {
      _result = ChallengeResult(
        stars: measures.stars,
        score: measures.score,
        title: measures.coherence == 100
            ? 'Plan tenu jusqu\'au bout'
            : 'Plan modifié en chemin',
        gauges: [
          ChallengeGauge('Cohérence avec le plan', measures.coherence),
          ChallengeGauge('Prudence', measures.prudence),
          ChallengeGauge('Sang-froid', measures.composure),
        ],
        afterwards:
            'Début octobre 2022, vos ${AppFormat.euro(mine.invested)} versés '
            'valent ${AppFormat.euro(mine.value)}. Le plan suivi sans faute : '
            '${AppFormat.euro(perfect.invested)} versés valent '
            '${AppFormat.euro(perfect.value)}.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prices = ref.watch(priceSeriesProvider(pricesId)).value?.points;
    return ChallengeScaffold(
      chapterNumber: widget.chapterNumber,
      situation: widget.challenge.situation,
      keyMessage: widget.challenge.keyMessage,
      result: _result,
      children: [
        if (prices == null)
          const SkeletonBox(height: 200)
        else if (_decisions.length < _months.length)
          _buildMonthCard(prices),
      ],
    );
  }

  Widget _buildMonthCard(List<PricePoint> prices) {
    final textTheme = Theme.of(context).textTheme;
    final month = _months[_decisions.length];
    final change = _monthChange(prices, month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'MOIS ${_decisions.length + 1} SUR ${_months.length}',
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppFormat.monthYear(month),
                  style: textTheme.headlineSmall,
                ),
              ),
              ChangeText.percent(change, style: textTheme.headlineSmall),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final option in _decisionOptions) ...[
          SelectableCard(
            title: option['label'] as String,
            onTap: () => _decide(prices, option),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
