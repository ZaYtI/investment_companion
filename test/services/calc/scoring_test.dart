import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/services/calc/scoring.dart';

void main() {
  group('score du défi', () {
    test('cohérence 90, prudence 60, sang-froid 85 donnent 78', () {
      expect(challengeScore(90, 60, 85), 78);
    });

    test('les étoiles changent à 50 et à 80', () {
      expect(starsForScore(49), 1);
      expect(starsForScore(50), 2);
      expect(starsForScore(79), 2);
      expect(starsForScore(80), 3);
    });
  });

  group('effet du chrono sur le sang-froid', () {
    test('une décision en moins de 3 s est un réflexe : −15', () {
      expect(timeModifier(2.99), -15);
    });

    test('une décision entre 3 et 12 s est réfléchie : +10', () {
      expect(timeModifier(3), 10);
      expect(timeModifier(12), 10);
    });

    test('le sang-froid ne dépasse jamais 100', () {
      expect(composureWithTime(95, 5), 100);
    });

    test('sans chrono, le sang-froid de base est gardé', () {
      expect(composureWithTime(85, null), 85);
    });
  });

  test('chapitre 4 : continuer tous les mois donne 100 partout', () {
    final measures = monthlyPlanMeasures(List.filled(6, MonthlyDecision.keep), [
      -0.09,
      0.0,
      -0.08,
      0.09,
      -0.04,
      -0.09,
    ]);
    expect(measures.score, 100);
  });
}
