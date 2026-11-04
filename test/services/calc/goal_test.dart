import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/services/calc/goal.dart';

void main() {
  group('capital final', () {
    test('150 € par mois pendant 8 ans à 5 % donnent 17 661 €', () {
      expect(futureValue(150, 0.05, 96), closeTo(17661.08, 0.01));
    });

    test('à 0 %, pas de division par zéro : on retrouve les versements', () {
      expect(futureValue(150, 0, 96), 14400);
    });

    test('Paul (50 € sur 30 ans) dépasse Marie (100 € sur 20 ans)', () {
      final paul = futureValue(50, 0.05, 360);
      final marie = futureValue(100, 0.05, 240);
      expect(paul, greaterThan(marie));
    });
  });

  group('versement nécessaire', () {
    test('pour 20 000 € en 8 ans à 5 %, il faut 169,87 € par mois', () {
      expect(requiredMonthly(20000, 0.05, 96), closeTo(169.87, 0.01));
    });

    test('verser ce montant redonne bien l\'objectif', () {
      final monthly = requiredMonthly(20000, 0.05, 96);
      expect(futureValue(monthly, 0.05, 96), closeTo(20000, 0.01));
    });
  });

  test('règle des 72 : à 6 %, un capital double en 12 ans', () {
    expect(ruleOf72(6), 12);
  });
}
