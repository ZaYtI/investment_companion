import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/models/price_point.dart';
import 'package:investment_companion/services/calc/dca.dart';
import 'package:investment_companion/services/calc/invalid_input_exception.dart';

void main() {
  final threeMonths = [
    PricePoint(date: DateTime(2022, 1, 3), close: 50),
    PricePoint(date: DateTime(2022, 2, 1), close: 40),
    PricePoint(date: DateTime(2022, 3, 1), close: 60),
  ];

  group('investissement mensuel', () {
    test('100 € à 50, 40 puis 60 € achètent 6,17 parts', () {
      final result = monthlyInvestment(threeMonths, amount: 100);
      expect(result.totalShares, closeTo(6.1667, 0.0001));
    });

    test(
      'le prix de revient moyen est de 48,65 €, sous la moyenne de 50 €',
      () {
        final result = monthlyInvestment(threeMonths, amount: 100);
        expect(result.averageCost, closeTo(48.65, 0.01));
      },
    );

    test('300 € versés valent 370 € au prix final de 60 €', () {
      final result = monthlyInvestment(threeMonths, amount: 100);
      expect(result.finalValue, closeTo(370, 0.01));
    });

    test('un versement nul est refusé', () {
      expect(
        () => monthlyInvestment(threeMonths, amount: 0),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('un historique vide est refusé', () {
      expect(
        () => monthlyInvestment([], amount: 100),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });

  group('premier cours du mois', () {
    test('un mois sans cours est ignoré et signalé', () {
      final prices = [threeMonths[0], threeMonths[2]];
      final months = firstPriceOfEachMonth(
        prices,
        from: DateTime(2022),
        to: DateTime(2022, 3),
      );
      expect(months.prices.length, 2);
      expect(months.skippedMonths, [DateTime(2022, 2)]);
    });
  });
}
