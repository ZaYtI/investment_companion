import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/progress_repository.dart';
import '../models/progress.dart';

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
  }) async {
    final current = await future;
    final updated = current.completeLevel(
      chapterNumber,
      levelIndex,
      xpEarned: xpEarned,
      stars: stars,
    );
    state = AsyncData(updated);
    await _repository.save(updated);
  }

  Future<void> saveChoice(String key, String value) async {
    final updated = (await future).withChoice(key, value);
    state = AsyncData(updated);
    await _repository.save(updated);
  }
}

final progressProvider = AsyncNotifierProvider<ProgressNotifier, Progress>(
  ProgressNotifier.new,
);

final currentProgressProvider = Provider<Progress>(
  (ref) => ref.watch(progressProvider).value ?? const Progress(),
);
