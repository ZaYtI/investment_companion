import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/daily_challenge.dart';
import '../../../providers/daily_challenge_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/simulation_providers.dart';
import '../../../services/calc/scoring.dart';
import '../../../services/daily_challenge.dart';
import '../../../services/day_keys.dart';
import '../../../services/progression.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/cards/selectable_card.dart';
import '../../widgets/progress/countdown_ring.dart';
import '../../widgets/states/empty_view.dart';
import '../../widgets/states/error_view.dart';
import 'daily_result_view.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  static const calmComposure = 70;
  static const choiceLetters = ['A', 'B', 'C'];
  static const choiceColors = [
    (AppColors.coralPale, AppColors.redText),
    (AppColors.mintPale, AppColors.mintText),
    (AppColors.background, AppColors.goldText),
  ];

  final _countdownKey = GlobalKey<CountdownRingState>();
  String? _planId;
  DailyResult? _result;

  void _decide(
    DailyChallengeContent content,
    DailyScenario scenario,
    DayMove move,
    String choiceId, {
    bool timedOut = false,
  }) {
    if (_result != null) return;
    final countdown = _countdownKey.currentState;
    countdown?.stop();
    final choice = content.choices.firstWhere((item) => item['id'] == choiceId);
    final scores =
        (choice['scores'] as Map<String, dynamic>)[_planId]
            as Map<String, dynamic>;
    final seconds = countdown == null || timedOut
        ? null
        : countdown.elapsedSeconds;
    final measures = ChallengeMeasures(
      coherence: scores['coherence'] as int,
      prudence: scores['prudence'] as int,
      composure: composureWithTime(scores['composure'] as int, seconds),
    );
    final progress = ref.read(progressProvider.notifier);
    progress.recordChallengeChoice(
      wasPatient: choiceId == 'doNothing',
      composure: measures.composure,
    );
    progress.recordDailyPlayed(
      challengeId: scenario.id,
      today: todayKey(),
      yesterday: yesterdayKey(),
      xpEarned: dailyChallengeXp,
    );
    setState(() {
      _result = DailyResult(
        measures: measures,
        title: measures.composure >= calmComposure
            ? 'Vous avez gardé votre calme'
            : 'Vous avez réagi à chaud',
        choiceLabel: timedOut
            ? 'Temps écoulé : ne rien faire'
            : choice['label'] as String,
        afterwards:
            'Un mois plus tard, le marché était à '
            '${AppFormat.signedPercent(move.changeOneMonthLater)} de son '
            'niveau de ce soir-là. Personne ne le savait ce jour-là.',
        xpEarned: dailyChallengeXp,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentValue = ref.watch(dailyChallengeContentProvider);
    final progress = ref.watch(currentProgressProvider);
    final hasPlayedToday = progress.hasPlayedDailyOn(todayKey());
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => context.pop()),
        title: Text(_result == null ? 'Défi du jour' : 'Résultat'),
      ),
      body: SafeArea(
        top: false,
        child: contentValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: ErrorView(message: 'Impossible de charger le défi du jour.'),
          ),
          data: (content) {
            final scenario = scenarioForToday(
              content.scenarios,
              playedIds: progress.playedDailyIds,
              hasPlayedToday: hasPlayedToday,
            );
            if (_result != null) {
              return DailyResultView(
                result: _result!,
                onContinue: () => context.pop(),
              );
            }
            if (hasPlayedToday) {
              return const Center(
                child: EmptyView(
                  message:
                      'Défi du jour terminé. Revenez demain pour un nouveau '
                      'défi et prolonger votre série.',
                  icon: Icons.check_circle_outline,
                ),
              );
            }
            final series = ref.watch(priceSeriesProvider(scenario.seriesId));
            final prices = series.value?.points;
            if (series.hasError) {
              return Center(
                child: ErrorView(
                  message: 'Impossible de charger les cours de ce jour.',
                  onRetry: () =>
                      ref.invalidate(priceSeriesProvider(scenario.seriesId)),
                ),
              );
            }
            if (prices == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final move = dayMoveOf(prices, scenario.date);
            return _planId == null
                ? _buildPlanStep(scenario)
                : _buildAlertStep(content, scenario, move);
          },
        ),
      ),
    );
  }

  Widget _buildPlanStep(DailyScenario scenario) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(appSettingsProvider).value;
    final content = ref.read(dailyChallengeContentProvider).value!;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Text(
          'DÉFI DU JOUR · ${AppFormat.fullDate(scenario.date).toUpperCase()}',
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Text("D'abord, votre plan", style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Une décision se juge par rapport à un plan fixé à froid.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        for (final plan in content.plans) ...[
          SelectableCard(
            title: plan['label'] as String,
            onTap: () => setState(() => _planId = plan['id'] as String),
          ),
          const SizedBox(height: 12),
        ],
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          activeTrackColor: AppColors.mint,
          title: const Text('Sans chrono'),
          subtitle: const Text('Prenez tout votre temps pour décider.'),
          value: !(settings?.isTimerEnabled ?? true),
          onChanged: (isWithoutTimer) => ref
              .read(appSettingsProvider.notifier)
              .setTimerEnabled(!isWithoutTimer),
        ),
      ],
    );
  }

  Widget _buildAlertStep(
    DailyChallengeContent content,
    DailyScenario scenario,
    DayMove move,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final isTimerEnabled =
        ref.read(appSettingsProvider).value?.isTimerEnabled ?? true;
    final valueTonight = content.capital * (1 + move.dayChange);
    final direction = move.dayChange < 0 ? 'chute' : 'monte';
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'ALERTE DU JOUR · '
                '${AppFormat.fullDate(scenario.date).toUpperCase()}',
                style: textTheme.labelMedium,
              ),
            ),
            if (isTimerEnabled)
              CountdownRing(
                key: _countdownKey,
                seconds: content.timerSeconds,
                onTimeout: () => _decide(
                  content,
                  scenario,
                  move,
                  content.timeoutChoice,
                  timedOut: true,
                ),
              ),
          ],
        ),
        Text(
          'La bourse $direction de '
          '${AppFormat.percent(move.dayChange.abs())} en une journée',
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          scenario.event,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Text(
          'Votre capital virtuel',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          children: [
            Text(
              AppFormat.euro(content.capital),
              style: textTheme.titleMedium?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '≈ ${AppFormat.euro(valueTonight)}',
              style: textTheme.displaySmall?.copyWith(
                color: move.dayChange < 0 ? AppColors.red : AppColors.mintText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Que faites-vous ?', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final (index, choice) in content.choices.indexed) ...[
          SelectableCard(
            leading: AppBadge.text(
              choiceLetters[index],
              background: choiceColors[index].$1,
              foreground: choiceColors[index].$2,
            ),
            title: choice['label'] as String,
            subtitle: choice['subtitle'] as String,
            onTap: () =>
                _decide(content, scenario, move, choice['id'] as String),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Simulation pédagogique. Ce n\'est pas un conseil financier.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
