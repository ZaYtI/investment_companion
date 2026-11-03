import '../models/progress.dart';
import '../models/progress_status.dart';

class BadgeStatus {
  final String id;
  final String title;
  final String condition;
  final int current;
  final int target;

  const BadgeStatus({
    required this.id,
    required this.title,
    required this.condition,
    required this.current,
    required this.target,
  });

  bool get isEarned => current >= target;
  bool get isStarted => current > 0;
}

const maxDiversifiedWeight = 0.6;
const minDiversifiedAssets = 3;
const composureBadgeThreshold = 80;

bool isDiversified(Map<String, double> weights) {
  final usedWeights = weights.values.where((weight) => weight > 0).toList();
  return usedWeights.length >= minDiversifiedAssets &&
      usedWeights.every((weight) => weight <= maxDiversifiedWeight);
}

int _atMost(int value, int maximum) => value > maximum ? maximum : value;

int _oneIf(bool condition) => condition ? 1 : 0;

List<BadgeStatus> evaluateBadges(
  Progress progress, {
  required int diversifiedSimulations,
}) {
  final completedChapters = [
    for (var chapter = 1; chapter <= Progress.chapterCount; chapter++)
      if (progress.statusOf(chapter) == ProgressStatus.completed) chapter,
  ];
  final threeStarRiskChapters = [
    2,
    3,
    6,
  ].where((chapter) => progress.starsByChapter[chapter] == 3).length;
  return [
    BadgeStatus(
      id: 'firstStep',
      title: 'Premier pas',
      condition: 'Terminer le premier niveau du chapitre 1.',
      current: _oneIf(progress.isLevelCompleted(1, 0)),
      target: 1,
    ),
    BadgeStatus(
      id: 'curious',
      title: 'Curieux',
      condition: "Ouvrir 5 fiches d'actifs et 3 écrans de contexte.",
      current:
          _atMost(progress.openedAssetIds.length, 5) +
          _atMost(progress.openedContextChapters.length, 3),
      target: 8,
    ),
    BadgeStatus(
      id: 'patience',
      title: 'Patience',
      condition:
          'Choisir « Continuer » ou « Ne rien faire » dans 5 défis '
          '(chapitres 3, 4, 6 et défis du jour).',
      current: _atMost(progress.patienceCount, 5),
      target: 5,
    ),
    BadgeStatus(
      id: 'composure',
      title: 'Sang-froid',
      condition: 'Avoir un sang-froid de 80 ou plus à un défi.',
      current: _oneIf(progress.bestComposure >= composureBadgeThreshold),
      target: 1,
    ),
    BadgeStatus(
      id: 'streak',
      title: 'Série de feu',
      condition: 'Faire le défi du jour 7 jours de suite.',
      current: _atMost(progress.bestStreakDays, 7),
      target: 7,
    ),
    BadgeStatus(
      id: 'diversifier',
      title: 'Diversificateur',
      condition:
          'Réussir le défi du chapitre 5 et enregistrer 2 simulations '
          'diversifiées (au moins 3 actifs, aucun au-dessus de 60 %).',
      current:
          _oneIf(progress.hasWonPortfolioChallenge) +
          _atMost(diversifiedSimulations, 2),
      target: 3,
    ),
    BadgeStatus(
      id: 'riskMaster',
      title: 'Maître du risque',
      condition: '3 étoiles aux défis des chapitres 2, 3 et 6.',
      current: threeStarRiskChapters,
      target: 3,
    ),
    BadgeStatus(
      id: 'goalReached',
      title: 'Objectif atteint',
      condition: 'Terminer le défi du chapitre 7 avec au moins 2 étoiles.',
      current: _oneIf((progress.starsByChapter[7] ?? 0) >= 2),
      target: 1,
    ),
    BadgeStatus(
      id: 'timeTraveler',
      title: 'Voyageur du temps',
      condition: 'Terminer les 7 chapitres.',
      current: completedChapters.length,
      target: Progress.chapterCount,
    ),
  ];
}
