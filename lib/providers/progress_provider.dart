import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/progress_repository.dart';
import '../models/progress.dart';
import '../services/badges.dart';
import 'saved_simulations_provider.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(),
);

class ProgressNotifier extends AsyncNotifier<Progress> {
  ProgressRepository get _repository => ref.read(progressRepositoryProvider);

  @override
  Future<Progress> build() => _repository.load();

  Future<void> completeLevel(
    int chapterNumber,
    int levelIndex, {
    required int xpEarned,
    int? stars,
  }) => _update(
    (progress) => progress.completeLevel(
      chapterNumber,
      levelIndex,
      xpEarned: xpEarned,
      stars: stars,
    ),
  );

  Future<void> skipChapter(int chapterNumber) =>
      _update((progress) => progress.skipChapter(chapterNumber));

  Future<void> addXp(int amount) =>
      _update((progress) => progress.addXp(amount));

  Future<void> recordOpenedAsset(String assetId) =>
      _update((progress) => progress.withOpenedAsset(assetId));

  Future<void> recordOpenedContext(int chapterNumber) =>
      _update((progress) => progress.withOpenedContext(chapterNumber));

  Future<void> recordChallengeChoice({
    required bool wasPatient,
    int? composure,
  }) => _update(
    (progress) => progress.withChallengeChoice(
      wasPatient: wasPatient,
      composure: composure,
    ),
  );

  Future<void> recordPortfolioChallengeWon() =>
      _update((progress) => progress.withPortfolioChallengeWon());

  Future<void> recordDailyPlayed({
    required String challengeId,
    required String today,
    required String yesterday,
    required int xpEarned,
  }) => _update(
    (progress) =>
        progress.withDailyPlayed(challengeId, today, yesterday).addXp(xpEarned),
  );

  Future<void> _update(Progress Function(Progress progress) change) async {
    final current = state.value ?? await future;
    final updated = change(current);
    state = AsyncData(updated);
    await _repository.save(updated);
  }

  Future<void> reset() async {
    state = const AsyncData(Progress());
    await _repository.clear();
  }

  Future<void> saveChoice(String key, String value) =>
      _update((progress) => progress.withChoice(key, value));
}

final progressProvider = AsyncNotifierProvider<ProgressNotifier, Progress>(
  ProgressNotifier.new,
);

final currentProgressProvider = Provider<Progress>(
  (ref) => ref.watch(progressProvider).value ?? const Progress(),
);

final badgesProvider = Provider<List<BadgeStatus>>((ref) {
  final progress = ref.watch(currentProgressProvider);
  final simulations = ref.watch(savedSimulationsProvider).value ?? [];
  final diversifiedSimulations = simulations
      .where((simulation) => isDiversified(simulation.weights))
      .length;
  return evaluateBadges(
    progress,
    diversifiedSimulations: diversifiedSimulations,
  );
});
