import 'progress_status.dart';

class Progress {
  static const levelsPerChapter = 3;
  static const chapterCount = 7;

  final Set<String> completedLevels;
  final Map<int, int> starsByChapter;
  final int xp;
  final Map<String, String> choices;
  final Set<String> openedAssetIds;
  final Set<int> openedContextChapters;
  final int patienceCount;
  final int bestComposure;
  final bool hasWonPortfolioChallenge;
  final List<String> playedDailyIds;
  final String? lastDailyDay;
  final int streakDays;
  final int bestStreakDays;

  const Progress({
    this.completedLevels = const {},
    this.starsByChapter = const {},
    this.xp = 0,
    this.choices = const {},
    this.openedAssetIds = const {},
    this.openedContextChapters = const {},
    this.patienceCount = 0,
    this.bestComposure = 0,
    this.hasWonPortfolioChallenge = false,
    this.playedDailyIds = const [],
    this.lastDailyDay,
    this.streakDays = 0,
    this.bestStreakDays = 0,
  });

  Progress copyWith({
    Set<String>? completedLevels,
    Map<int, int>? starsByChapter,
    int? xp,
    Map<String, String>? choices,
    Set<String>? openedAssetIds,
    Set<int>? openedContextChapters,
    int? patienceCount,
    int? bestComposure,
    bool? hasWonPortfolioChallenge,
    List<String>? playedDailyIds,
    String? lastDailyDay,
    int? streakDays,
    int? bestStreakDays,
  }) {
    return Progress(
      completedLevels: completedLevels ?? this.completedLevels,
      starsByChapter: starsByChapter ?? this.starsByChapter,
      xp: xp ?? this.xp,
      choices: choices ?? this.choices,
      openedAssetIds: openedAssetIds ?? this.openedAssetIds,
      openedContextChapters:
          openedContextChapters ?? this.openedContextChapters,
      patienceCount: patienceCount ?? this.patienceCount,
      bestComposure: bestComposure ?? this.bestComposure,
      hasWonPortfolioChallenge:
          hasWonPortfolioChallenge ?? this.hasWonPortfolioChallenge,
      playedDailyIds: playedDailyIds ?? this.playedDailyIds,
      lastDailyDay: lastDailyDay ?? this.lastDailyDay,
      streakDays: streakDays ?? this.streakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
    );
  }

  static String horizonChoiceKey(int chapterNumber) => '$chapterNumber.horizon';

  static String levelKey(int chapterNumber, int levelIndex) =>
      '$chapterNumber.$levelIndex';

  bool isLevelCompleted(int chapterNumber, int levelIndex) =>
      completedLevels.contains(levelKey(chapterNumber, levelIndex));

  int completedLevelsIn(int chapterNumber) {
    var count = 0;
    while (count < levelsPerChapter && isLevelCompleted(chapterNumber, count)) {
      count++;
    }
    return count;
  }

  int get currentChapter {
    for (var chapter = 1; chapter <= chapterCount; chapter++) {
      if (completedLevelsIn(chapter) < levelsPerChapter) return chapter;
    }
    return chapterCount;
  }

  ProgressStatus statusOf(int chapterNumber) {
    if (completedLevelsIn(chapterNumber) == levelsPerChapter) {
      return ProgressStatus.completed;
    }
    if (chapterNumber == currentChapter) return ProgressStatus.current;
    return ProgressStatus.locked;
  }

  ProgressStatus levelStatusOf(int chapterNumber, int levelIndex) {
    if (statusOf(chapterNumber) == ProgressStatus.locked) {
      return ProgressStatus.locked;
    }
    final completedLevels = completedLevelsIn(chapterNumber);
    if (levelIndex < completedLevels) return ProgressStatus.completed;
    if (levelIndex == completedLevels) return ProgressStatus.current;
    return ProgressStatus.locked;
  }

  Progress completeLevel(
    int chapterNumber,
    int levelIndex, {
    required int xpEarned,
    int? stars,
  }) {
    final key = levelKey(chapterNumber, levelIndex);
    final isFirstTime = !completedLevels.contains(key);
    final newStars = {...starsByChapter};
    final previousStars = starsByChapter[chapterNumber] ?? 0;
    if (stars != null && stars > previousStars) {
      newStars[chapterNumber] = stars;
    }
    return copyWith(
      completedLevels: {...completedLevels, key},
      starsByChapter: newStars,
      xp: isFirstTime ? xp + xpEarned : xp,
    );
  }

  Progress skipChapter(int chapterNumber) {
    return copyWith(
      completedLevels: {
        ...completedLevels,
        for (var level = 0; level < levelsPerChapter; level++)
          levelKey(chapterNumber, level),
      },
    );
  }

  Progress withChoice(String key, String value) {
    return copyWith(choices: {...choices, key: value});
  }

  Progress addXp(int amount) => copyWith(xp: xp + amount);

  Progress withOpenedAsset(String assetId) =>
      copyWith(openedAssetIds: {...openedAssetIds, assetId});

  Progress withOpenedContext(int chapterNumber) => copyWith(
    openedContextChapters: {...openedContextChapters, chapterNumber},
  );

  Progress withChallengeChoice({required bool wasPatient, int? composure}) {
    return copyWith(
      patienceCount: wasPatient ? patienceCount + 1 : patienceCount,
      bestComposure: composure != null && composure > bestComposure
          ? composure
          : bestComposure,
    );
  }

  Progress withPortfolioChallengeWon() =>
      copyWith(hasWonPortfolioChallenge: true);

  bool hasPlayedDailyOn(String day) => lastDailyDay == day;

  int currentStreak({required String today, required String yesterday}) {
    final isStillRunning = lastDailyDay == today || lastDailyDay == yesterday;
    return isStillRunning ? streakDays : 0;
  }

  Progress withDailyPlayed(String challengeId, String today, String yesterday) {
    final newStreak = lastDailyDay == yesterday ? streakDays + 1 : 1;
    return copyWith(
      playedDailyIds: [...playedDailyIds, challengeId],
      lastDailyDay: today,
      streakDays: newStreak,
      bestStreakDays: newStreak > bestStreakDays ? newStreak : bestStreakDays,
    );
  }

  factory Progress.fromJson(Map<String, dynamic> json) {
    final stars = json['starsByChapter'] as Map<String, dynamic>;
    return Progress(
      completedLevels: (json['completedLevels'] as List<dynamic>)
          .cast<String>()
          .toSet(),
      starsByChapter: {
        for (final entry in stars.entries)
          int.parse(entry.key): entry.value as int,
      },
      xp: json['xp'] as int,
      choices: (json['choices'] as Map<String, dynamic>).cast<String, String>(),
      openedAssetIds: (json['openedAssetIds'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
      openedContextChapters:
          (json['openedContextChapters'] as List<dynamic>? ?? [])
              .cast<int>()
              .toSet(),
      patienceCount: json['patienceCount'] as int? ?? 0,
      bestComposure: json['bestComposure'] as int? ?? 0,
      hasWonPortfolioChallenge:
          json['hasWonPortfolioChallenge'] as bool? ?? false,
      playedDailyIds: (json['playedDailyIds'] as List<dynamic>? ?? [])
          .cast<String>(),
      lastDailyDay: json['lastDailyDay'] as String?,
      streakDays: json['streakDays'] as int? ?? 0,
      bestStreakDays: json['bestStreakDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'completedLevels': completedLevels.toList(),
    'starsByChapter': {
      for (final entry in starsByChapter.entries) '${entry.key}': entry.value,
    },
    'xp': xp,
    'choices': choices,
    'openedAssetIds': openedAssetIds.toList(),
    'openedContextChapters': openedContextChapters.toList(),
    'patienceCount': patienceCount,
    'bestComposure': bestComposure,
    'hasWonPortfolioChallenge': hasWonPortfolioChallenge,
    'playedDailyIds': playedDailyIds,
    'lastDailyDay': lastDailyDay,
    'streakDays': streakDays,
    'bestStreakDays': bestStreakDays,
  };
}
