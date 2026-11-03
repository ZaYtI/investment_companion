import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/challenge_level.dart';
import '../../../models/progress.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/calc/scoring.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/selectable_card.dart';
import '../../widgets/progress/countdown_ring.dart';
import 'challenge_scaffold.dart';

class DecisionChallengeScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final ChallengeLevel challenge;

  const DecisionChallengeScreen({
    super.key,
    required this.chapterNumber,
    required this.challenge,
  });

  @override
  ConsumerState<DecisionChallengeScreen> createState() =>
      _DecisionChallengeScreenState();
}

class _DecisionChallengeScreenState
    extends ConsumerState<DecisionChallengeScreen> {
  static const calmComposure = 70;
  static const patientChoiceIds = {'keep', 'doNothing'};

  late final _data = widget.challenge.data;
  late final List<Map<String, dynamic>> _plans = (_data['plans'] as List)
      .cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _choices = (_data['choices'] as List)
      .cast<Map<String, dynamic>>();
  late final int? _contentTimerSeconds = _data['timerSeconds'] as int?;
  late final bool _planComesFromSimulation = _data['planFromLevel'] != null;

  final _countdownKey = GlobalKey<CountdownRingState>();
  String? _planId;
  ChallengeResult? _result;

  @override
  void initState() {
    super.initState();
    if (_planComesFromSimulation) {
      final key = Progress.horizonChoiceKey(widget.chapterNumber);
      final savedPlan = ref.read(currentProgressProvider).choices[key];
      _planId = savedPlan ?? _plans.last['id'] as String;
    }
  }

  int? get _timerSeconds {
    final isTimerEnabled =
        ref.read(appSettingsProvider).value?.isTimerEnabled ?? true;
    return isTimerEnabled ? _contentTimerSeconds : null;
  }

  void _choosePlan(String planId) {
    setState(() => _planId = planId);
  }

  void _onTimeout() {
    _decide(_data['timeoutChoice'] as String, timedOut: true);
  }

  void _decide(String choiceId, {bool timedOut = false}) {
    final countdown = _countdownKey.currentState;
    countdown?.stop();
    final choice = _choices.firstWhere((choice) => choice['id'] == choiceId);
    final scores =
        (choice['scores'] as Map<String, dynamic>)[_planId]
            as Map<String, dynamic>;
    final coherence = scores['coherence'] as int;
    final prudence = scores['prudence'] as int;
    final baseComposure = scores['composure'] as int?;
    final wasPatient = patientChoiceIds.contains(choiceId);
    final afterwards = [
      if (choice['afterwards'] != null) choice['afterwards'] as String,
      _data['afterwards'] as String,
    ].join(' ');

    if (baseComposure == null) {
      ref
          .read(progressProvider.notifier)
          .recordChallengeChoice(wasPatient: wasPatient);
      final score = crisisScore(coherence, prudence);
      setState(() {
        _result = ChallengeResult(
          stars: starsForScore(score),
          score: score,
          title: 'Vous avez choisi : ${choice['label']}',
          gauges: [
            ChallengeGauge('Cohérence avec votre horizon', coherence),
            ChallengeGauge('Prudence', prudence),
          ],
          afterwards: afterwards,
        );
      });
      return;
    }

    final seconds = countdown == null || timedOut
        ? null
        : countdown.elapsedSeconds;
    final composure = composureWithTime(baseComposure, seconds);
    ref
        .read(progressProvider.notifier)
        .recordChallengeChoice(wasPatient: wasPatient, composure: composure);
    final measures = ChallengeMeasures(
      coherence: coherence,
      prudence: prudence,
      composure: composure,
    );
    setState(() {
      _result = ChallengeResult(
        stars: measures.stars,
        score: measures.score,
        title: composure >= calmComposure
            ? 'Vous avez gardé votre calme'
            : 'Vous avez réagi à chaud',
        gauges: [
          ChallengeGauge('Cohérence avec votre plan', coherence),
          ChallengeGauge('Prudence', prudence),
          ChallengeGauge('Sang-froid', composure),
        ],
        explanation: timedOut
            ? 'Le temps est écoulé : vous n\'avez rien fait.'
            : 'Vous avez choisi : ${choice['label']}.',
        afterwards: afterwards,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final planId = _planId;
    final timerSeconds = _timerSeconds;
    return ChallengeScaffold(
      chapterNumber: widget.chapterNumber,
      situation: widget.challenge.situation,
      keyMessage: widget.challenge.keyMessage,
      result: _result,
      children: [
        if (planId == null) ...[
          Text("D'abord, votre plan", style: textTheme.labelMedium),
          const SizedBox(height: 8),
          for (final plan in _plans) ...[
            SelectableCard(
              title: plan['label'] as String,
              onTap: () => _choosePlan(plan['id'] as String),
            ),
            const SizedBox(height: 12),
          ],
        ] else ...[
          Text(
            'Votre plan : ${_plans.firstWhere((plan) => plan['id'] == planId)['label']}',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (timerSeconds != null) ...[
            const SizedBox(height: 12),
            Center(
              child: CountdownRing(
                key: _countdownKey,
                seconds: timerSeconds,
                onTimeout: _onTimeout,
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (final choice in _choices) ...[
            SelectableCard(
              title: choice['label'] as String,
              onTap: () => _decide(choice['id'] as String),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}
