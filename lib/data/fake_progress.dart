import '../models/progress_status.dart';

class FakeProgress {
  static const xp = 340;
  static const streakDays = 3;
  static const currentChapter = 3;
  static const completedLevelsInCurrentChapter = 1;
  static const levelsPerChapter = 3;
  static const starsByChapter = {1: 3, 2: 3, 3: 2};

  static ProgressStatus statusOf(int chapterNumber) {
    if (chapterNumber < currentChapter) return ProgressStatus.completed;
    if (chapterNumber == currentChapter) return ProgressStatus.current;
    return ProgressStatus.locked;
  }

  static int completedLevelsIn(int chapterNumber) {
    return switch (statusOf(chapterNumber)) {
      ProgressStatus.completed => levelsPerChapter,
      ProgressStatus.current => completedLevelsInCurrentChapter,
      ProgressStatus.locked => 0,
    };
  }

  static ProgressStatus levelStatusOf(int chapterNumber, int levelIndex) {
    if (statusOf(chapterNumber) == ProgressStatus.locked) {
      return ProgressStatus.locked;
    }
    final completedLevels = completedLevelsIn(chapterNumber);
    if (levelIndex < completedLevels) return ProgressStatus.completed;
    if (levelIndex == completedLevels) return ProgressStatus.current;
    return ProgressStatus.locked;
  }
}
