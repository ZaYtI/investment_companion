import '../models/chapter_status.dart';

class FakeProgress {
  static const xp = 340;
  static const streakDays = 3;
  static const currentChapter = 4;
  static const completedLevelsInCurrentChapter = 1;
  static const levelsPerChapter = 3;
  static const starsByChapter = {1: 3, 2: 3, 3: 2};

  static ChapterStatus statusOf(int chapterNumber) {
    if (chapterNumber < currentChapter) return ChapterStatus.completed;
    if (chapterNumber == currentChapter) return ChapterStatus.current;
    return ChapterStatus.locked;
  }
}
