import '../models/progress.dart';
import '../models/progress_status.dart';

class BadgeStep {
  final String label;
  final int current;
  final int target;

  const BadgeStep(this.label, this.current, this.target);

  bool get isDone => current >= target;
}

class BadgeStatus {
  final String id;
  final String title;
  final String condition;
  final String meaning;
  final String hint;
  final int current;
  final int target;
  final List<BadgeStep> steps;

  const BadgeStatus({
    required this.id,
    required this.title,
    required this.condition,
    required this.meaning,
    required this.hint,
    required this.current,
    required this.target,
    required this.steps,
  });

  bool get isEarned => current >= target;
  bool get isStarted => current > 0;
  double get progress => current / target;
}

const maxDiversifiedWeight = 0.6;
const minDiversifiedAssets = 3;
const composureBadgeThreshold = 80;
const maxStars = 3;

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
  int starsOf(int chapter) => progress.starsByChapter[chapter] ?? 0;
  const riskChapters = [2, 3, 6];
  final openedAssets = _atMost(progress.openedAssetIds.length, 5);
  final openedContexts = _atMost(progress.openedContextChapters.length, 3);
  final diversified = _atMost(diversifiedSimulations, 2);

  return [
    BadgeStatus(
      id: 'firstStep',
      title: 'Premier pas',
      condition: 'Terminer le premier niveau du chapitre 1.',
      meaning:
          'Le premier pas est souvent le plus difficile : vous avez '
          'commencé à apprendre.',
      hint:
          'Sur la carte, ouvrez le chapitre 1 et faites la leçon '
          '« Comprendre ».',
      current: _oneIf(progress.isLevelCompleted(1, 0)),
      target: 1,
      steps: [
        BadgeStep(
          'Leçon du chapitre 1',
          _oneIf(progress.isLevelCompleted(1, 0)),
          1,
        ),
      ],
    ),
    BadgeStatus(
      id: 'curious',
      title: 'Curieux',
      condition: "Ouvrir 5 fiches d'actifs et 3 écrans de contexte.",
      meaning:
          'Comparer des actifs et comprendre chaque époque aide à '
          'décider avec du recul.',
      hint:
          'Ouvrez des fiches dans l\'onglet Explorer, et le bouton '
          '« Contexte de l\'époque » dans les chapitres 2 à 7.',
      current: openedAssets + openedContexts,
      target: 8,
      steps: [
        BadgeStep("Fiches d'actifs ouvertes", openedAssets, 5),
        BadgeStep('Écrans de contexte ouverts', openedContexts, 3),
      ],
    ),
    BadgeStatus(
      id: 'patience',
      title: 'Patience',
      condition:
          'Choisir « Continuer » ou « Ne rien faire » dans 5 défis '
          '(chapitres 3, 4, 6 et défis du jour).',
      meaning:
          'Garder son plan pendant une baisse est souvent la décision '
          'la plus difficile, et la plus utile.',
      hint:
          'Dans les défis des chapitres 3, 4 et 6 et dans le défi du '
          'jour, gardez votre plan : « Garder », « Continuer » ou '
          '« Ne rien faire ».',
      current: _atMost(progress.patienceCount, 5),
      target: 5,
      steps: [
        BadgeStep(
          'Défis où vous avez gardé votre plan',
          _atMost(progress.patienceCount, 5),
          5,
        ),
      ],
    ),
    BadgeStatus(
      id: 'composure',
      title: 'Sang-froid',
      condition: 'Avoir un sang-froid de 80 ou plus à un défi.',
      meaning: 'Décider à froid plutôt que sous le coup de la peur.',
      hint:
          'Au défi du chapitre 6 ou au défi du jour, choisissez une '
          'décision cohérente avec votre plan et prenez entre 3 et 12 '
          'secondes pour réfléchir.',
      current: _oneIf(progress.bestComposure >= composureBadgeThreshold),
      target: 1,
      steps: [
        BadgeStep(
          'Meilleur sang-froid obtenu',
          _atMost(progress.bestComposure, composureBadgeThreshold),
          composureBadgeThreshold,
        ),
      ],
    ),
    BadgeStatus(
      id: 'streak',
      title: 'Série de feu',
      condition: 'Faire le défi du jour 7 jours de suite.',
      meaning:
          'La régularité compte plus que les coups d\'éclat, en '
          'apprentissage comme en investissement.',
      hint:
          'Faites le défi du jour depuis la carte, un jour après '
          'l\'autre. Un jour manqué remet la série à zéro.',
      current: _atMost(progress.bestStreakDays, 7),
      target: 7,
      steps: [
        BadgeStep(
          'Meilleure série de jours',
          _atMost(progress.bestStreakDays, 7),
          7,
        ),
      ],
    ),
    BadgeStatus(
      id: 'diversifier',
      title: 'Diversificateur',
      condition:
          'Réussir le défi du chapitre 5 et enregistrer 2 simulations '
          'diversifiées (au moins 3 actifs, aucun au-dessus de 60 %).',
      meaning: 'Ne pas mettre tous ses œufs dans le même panier.',
      hint:
          'Réussissez le défi du chapitre 5, puis enregistrez dans '
          'l\'onglet Simulations des portefeuilles d\'au moins 3 actifs.',
      current: _oneIf(progress.hasWonPortfolioChallenge) + diversified,
      target: 3,
      steps: [
        BadgeStep(
          'Défi du chapitre 5 réussi',
          _oneIf(progress.hasWonPortfolioChallenge),
          1,
        ),
        BadgeStep('Simulations diversifiées enregistrées', diversified, 2),
      ],
    ),
    BadgeStatus(
      id: 'riskMaster',
      title: 'Maître du risque',
      condition: '3 étoiles aux défis des chapitres 2, 3 et 6.',
      meaning: 'Vous comprenez le risque, les baisses et les crises.',
      hint:
          'Obtenez 3 étoiles aux défis des chapitres 2, 3 et 6. Vous '
          'pouvez les rejouer : seule la meilleure note est gardée.',
      current: riskChapters
          .where((chapter) => starsOf(chapter) == maxStars)
          .length,
      target: riskChapters.length,
      steps: [
        for (final chapter in riskChapters)
          BadgeStep(
            'Étoiles au défi du chapitre $chapter',
            starsOf(chapter),
            maxStars,
          ),
      ],
    ),
    BadgeStatus(
      id: 'goalReached',
      title: 'Objectif atteint',
      condition: 'Terminer le défi du chapitre 7 avec au moins 2 étoiles.',
      meaning: 'Vous savez bâtir un plan tenable vers un objectif.',
      hint:
          'Faites le défi du chapitre 7 : votre plan doit aussi résister '
          'au test de 2008.',
      current: _oneIf(starsOf(7) >= 2),
      target: 1,
      steps: [BadgeStep('Étoiles au défi du chapitre 7', starsOf(7), 2)],
    ),
    BadgeStatus(
      id: 'timeTraveler',
      title: 'Voyageur du temps',
      condition: 'Terminer les 7 chapitres.',
      meaning: 'Vous avez traversé toutes les époques du parcours.',
      hint: 'Terminez les trois niveaux de chaque chapitre sur la carte.',
      current: completedChapters.length,
      target: Progress.chapterCount,
      steps: [
        BadgeStep(
          'Chapitres terminés',
          completedChapters.length,
          Progress.chapterCount,
        ),
      ],
    ),
  ];
}
