import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/challenge_level.dart';
import '../../../providers/simulation_providers.dart';
import '../../../services/calc/portfolio.dart';
import '../../../services/calc/scoring.dart';
import '../../format/app_format.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/selectable_card.dart';
import '../simulate/simulator_widgets.dart';
import '../simulate/weights_editor.dart';
import 'challenge_scaffold.dart';

class RiskProfileChallengeScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final ChallengeLevel challenge;

  const RiskProfileChallengeScreen({
    super.key,
    required this.chapterNumber,
    required this.challenge,
  });

  @override
  ConsumerState<RiskProfileChallengeScreen> createState() =>
      _RiskProfileChallengeScreenState();
}

class _RiskProfileChallengeScreenState
    extends ConsumerState<RiskProfileChallengeScreen> {
  static const firstWindowYear = 2018;
  static const lastWindowYear = 2023;

  late final _data = widget.challenge.data;
  late final List<Map<String, dynamic>> _questions =
      (_data['profileQuestions'] as List).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _bands = (_data['bands'] as List)
      .cast<Map<String, dynamic>>();
  late final List<String> _assets = (_data['assets'] as List).cast<String>();
  late final int _windowYears = _data['windowYears'] as int;

  final _answers = <Map<String, dynamic>>[];
  late var _percents = {for (final asset in _assets) asset: 0};
  var _isRunning = false;
  ChallengeResult? _result;

  bool get _hasAnsweredProfile => _answers.length == _questions.length;

  int get _totalPercent =>
      _percents.values.fold(0, (sum, percent) => sum + percent);

  Map<String, dynamic> get _profileBand {
    final points = _answers.fold(
      0,
      (sum, answer) => sum + (answer['points'] as int),
    );
    return _bands.firstWhere((band) => points <= (band['maxPoints'] as int));
  }

  double get _acceptedLoss => (_answers.first['maxLoss'] as num).toDouble();

  Future<void> _run() async {
    setState(() => _isRunning = true);
    final startYear =
        firstWindowYear + Random().nextInt(lastWindowYear - firstWindowYear);
    final start = DateTime(startYear);
    final end = DateTime(startYear + _windowYears);
    final weights = {
      for (final entry in _percents.entries) entry.key: entry.value / 100,
    };
    final isOnlyCash = weights[cashId] == 1;
    var volatility = 0.0;
    var drawdown = 0.0;
    if (!isOnlyCash) {
      final result = await ref
          .read(simulationServiceProvider)
          .simulate(weights: weights, start: start, end: end, amount: 10000);
      volatility = result.volatility ?? 0;
      drawdown = result.maxDrawdown;
    }
    final band = _profileBand;
    final prudence = riskPrudence(drawdown, _acceptedLoss);
    final coherence = riskCoherence(
      volatility,
      RiskBand.values.byName(band['id'] as String),
    );
    setState(() {
      _isRunning = false;
      _result = ChallengeResult(
        stars: riskProfileStars(prudence, coherence),
        title: 'Votre profil : ${band['label']}',
        gauges: [
          ChallengeGauge('Prudence', prudence),
          ChallengeGauge('Cohérence avec votre profil', coherence),
        ],
        explanation:
            'Votre répartition rejouée de janvier $startYear à janvier '
            '${startYear + _windowYears} : pire baisse '
            '${AppFormat.percent(drawdown)} pour une perte acceptée de '
            '${AppFormat.percent(_acceptedLoss)}, volatilité de '
            '${AppFormat.percent(volatility)} par an.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ChallengeScaffold(
      chapterNumber: widget.chapterNumber,
      situation: widget.challenge.situation,
      keyMessage: widget.challenge.keyMessage,
      result: _result,
      children: [
        if (!_hasAnsweredProfile)
          ..._buildQuestion(_questions[_answers.length])
        else ...[
          Text(
            'Votre profil : ${_profileBand['label']}',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Répartissez vos 10 000 €. Les liquidités ne bougent pas.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          WeightsEditor(
            assetLabels: {
              for (final asset in _assets) asset: assetLabels[asset]!,
            },
            percents: _percents,
            onChanged: (percents) => setState(() => _percents = percents),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Rejouer sur 3 ans',
            isLoading: _isRunning,
            onPressed: _totalPercent == 100 ? _run : null,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildQuestion(Map<String, dynamic> question) {
    final choices = (question['choices'] as List).cast<Map<String, dynamic>>();
    return [
      Text(
        'QUESTION ${_answers.length + 1} SUR ${_questions.length}',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(height: 8),
      Text(
        question['question'] as String,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 16),
      for (final choice in choices) ...[
        SelectableCard(
          title: choice['label'] as String,
          onTap: () => setState(() => _answers.add(choice)),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }
}
