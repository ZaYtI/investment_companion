import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/models/price_point.dart';
import 'package:investment_companion/services/calc/invalid_input_exception.dart';
import 'package:investment_companion/services/calc/portfolio.dart';

void main() {
  final dates = [DateTime(2000), DateTime(2001)];

  group('valeur du portefeuille', () {
    test('60 % qui perd 20 % et 40 % qui gagne 10 % donnent 9 200 €', () {
      final result = buyAndHold(
        capital: 10000,
        weights: {'a': 0.6, 'b': 0.4},
        prices: {
          'a': [100, 80],
          'b': [100, 110],
        },
        dates: dates,
      );
      expect(result.finalValue, closeTo(9200, 0.01));
    });

    test('les pondérations dérivent mais font toujours 100 %', () {
      final result = buyAndHold(
        capital: 10000,
        weights: {'a': 0.6, 'b': 0.4},
        prices: {
          'a': [100, 80],
          'b': [100, 110],
        },
        dates: dates,
      );
      final totalWeight = result.weightsAt(1).values.reduce((a, b) => a + b);
      expect(totalWeight, closeTo(1, 0.0001));
    });

    test('des pondérations à 99 % sont refusées', () {
      expect(
        () => buyAndHold(
          capital: 10000,
          weights: {'a': 0.99},
          prices: {
            'a': [1, 1],
          },
          dates: dates,
        ),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('un capital nul est refusé', () {
      expect(
        () => buyAndHold(
          capital: 0,
          weights: {'a': 1},
          prices: {
            'a': [1, 1],
          },
          dates: dates,
        ),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('alignement des dates', () {
    test('un jour sans cours reprend le dernier cours connu', () {
      final series = [
        PricePoint(date: DateTime(2020, 1, 1), close: 1),
        PricePoint(date: DateTime(2020, 1, 3), close: 3),
      ];
      final aligned = alignOnDates(series, [
        DateTime(2020, 1, 1),
        DateTime(2020, 1, 2),
        DateTime(2020, 1, 3),
      ]);
      expect(aligned, [1, 1, 3]);
    });

    test('une date avant le début de l\'historique est refusée', () {
      final series = [PricePoint(date: DateTime(2020), close: 1)];
      expect(
        () => alignOnDates(series, [DateTime(2019)]),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });
}
