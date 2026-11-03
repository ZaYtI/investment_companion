const quizAnswerXp = 10;
const dailyChallengeXp = 30;

class PlayerLevel {
  final int number;
  final String title;
  final int minXp;

  const PlayerLevel(this.number, this.title, this.minXp);
}

const playerLevels = [
  PlayerLevel(1, 'Curieux', 0),
  PlayerLevel(2, 'Apprenti', 100),
  PlayerLevel(3, 'Éclaireur', 200),
  PlayerLevel(4, 'Explorateur', 300),
  PlayerLevel(5, 'Stratège', 500),
  PlayerLevel(6, 'Voyageur', 700),
  PlayerLevel(7, 'Gardien du sang-froid', 900),
  PlayerLevel(8, 'Investisseur chevronné', 1200),
];

PlayerLevel levelForXp(int xp) {
  return playerLevels.lastWhere((level) => xp >= level.minXp);
}

PlayerLevel? nextLevelAfter(PlayerLevel level) {
  final index = playerLevels.indexOf(level);
  if (index == playerLevels.length - 1) return null;
  return playerLevels[index + 1];
}

int xpToNextLevel(int xp) {
  final next = nextLevelAfter(levelForXp(xp));
  return next == null ? 0 : next.minXp - xp;
}

double progressInLevel(int xp) {
  final level = levelForXp(xp);
  final next = nextLevelAfter(level);
  if (next == null) return 1;
  return (xp - level.minXp) / (next.minXp - level.minXp);
}
