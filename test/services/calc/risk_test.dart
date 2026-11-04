import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/services/calc/invalid_input_exception.dart';
import 'package:investment_companion/services/calc/risk.dart';

void main() {
  group('volatilité', () {
    test('les variations de A (±1 à 2 %) donnent un écart type de 1,58 %', () {
      final weeklyChanges = [0.01, -0.01, 0.02, -0.02, 0.0];
      expect(
        sampleStdDev(weeklyChanges, minPoints: 2),
        closeTo(0.0158, 0.0001),
      );
    });

    test('un prix constant a une volatilité nulle', () {
      final prices = List.filled(10, 100.0);
      expect(annualizedVolatility(returnsFromPrices(prices)), 0);
    });

    test('moins de 8 points de données sont refusés', () {
      expect(
        () => annualizedVolatility([0.01, 0.02]),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('pire baisse', () {
    test('elle se mesure depuis le plus haut atteint : 120 → 90 = −25 %', () {
      final drawdown = maxDrawdown([100, 120, 90, 130, 100]);
      expect(drawdown.percent, closeTo(-0.25, 0.0001));
    });

    test('une série toujours croissante n\'a aucune baisse', () {
      expect(maxDrawdown([1, 2, 3]).hasDrop, isFalse);
    });

    test('un historique vide est refusé', () {
      expect(() => maxDrawdown([]), throwsA(isA<InvalidInputException>()));
    });

    test('une valeur nulle dans l\'historique est refusée', () {
      expect(
        () => maxDrawdown([10, 0, 12]),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('gain nécessaire pour revenir', () {
    test('après −50 %, il faut +100 %', () {
      expect(requiredGain(-0.5), closeTo(1, 0.0001));
    });

    test('une perte totale ne se rattrape pas', () {
      expect(() => requiredGain(-1), throwsA(isA<InvalidInputException>()));
    });
  });
}
