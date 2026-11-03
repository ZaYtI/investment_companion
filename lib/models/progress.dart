import 'progress_status.dart';

class Progress {
  static const levelsPerChapter = 3;
  static const chapterCount = 7;

  final Set<String> completedLevels;
  final Map<int, int> starsByChapter;
  final int xp;
  final Map<String, String> choices;

  const Progress({
    this.completedLevels = const {},
    this.starsByChapter = const {},
    this.xp = 0,
    this.choices = const {},
  });

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
    return Progress(
      completedLevels: {...completedLevels, key},
      starsByChapter: newStars,
      xp: isFirstTime ? xp + xpEarned : xp,
      choices: choices,
    );
  }

  Progress withChoice(String key, String value) {
    return Progress(
      completedLevels: completedLevels,
      starsByChapter: starsByChapter,
      xp: xp,
      choices: {...choices, key: value},
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
    );
  }

  Map<String, dynamic> toJson() => {
    'completedLevels': completedLevels.toList(),
    'starsByChapter': {
      for (final entry in starsByChapter.entries) '${entry.key}': entry.value,
    },
    'xp': xp,
    'choices': choices,
  };
}
