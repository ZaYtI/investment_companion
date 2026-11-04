import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/services/calc/invalid_input_exception.dart';
import 'package:investment_companion/services/calc/performance.dart';

void main() {
  group('gain', () {
    test('4 parts achetées 25 € puis revendues 30 € rapportent 20 €', () {
      expect(gain(4, 25, 30), 20);
    });

    test('un prix inchangé donne un gain nul', () {
      expect(gain(3, 10, 10), 0);
    });

    test('un prix d\'achat nul est refusé', () {
      expect(() => gain(1, 0, 10), throwsA(isA<InvalidInputException>()));
    });
  });

  group('performance', () {
    test('de 80 € à 100 €, la performance est de +25 %', () {
      expect(performance(80, 100), closeTo(0.25, 0.0001));
    });

    test('de 100 € à 50 €, la performance est de −50 %', () {
      expect(performance(100, 50), closeTo(-0.5, 0.0001));
    });

    test('un prix de départ nul est refusé au lieu de diviser par zéro', () {
      expect(() => performance(0, 100), throwsA(isA<InvalidInputException>()));
    });
  });

  group('variation', () {
    test('−9 % puis +5 % ne ramène pas à 10 000 €', () {
      final afterDrop = 10000 * (1 + variation(10000, 9100));
      final afterRise = afterDrop * (1 + variation(9100, 9555));
      expect(afterRise, closeTo(9555, 0.01));
    });
  });
}
