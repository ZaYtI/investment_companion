import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/series_transform.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('docs/api/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('parseTimeSeries', () {
    test('convertit les cours reçus en chaînes', () {
      final points = parseTimeSeries(
        _fixture('twelvedata_time_series_spy_1week_2013.json'),
      );
      expect(points, hasLength(52));
      expect(points.first.date, DateTime(2013, 1, 7));
      expect(points.first.close, closeTo(147.07, 0.01));
    });

    test('trie par date croissante quel que soit l\'ordre reçu', () {
      final points = parseTimeSeries({
        'status': 'ok',
        'values': [
          {'datetime': '2022-02-01', 'close': '2'},
          {'datetime': '2022-01-01', 'close': '1'},
        ],
      });
      expect(points.map((p) => p.close), [1, 2]);
    });

    test('lève une erreur typée sur un quota dépassé', () {
      expect(
        () => parseTimeSeries(_fixture('twelvedata_error_429_quota.json')),
        throwsA(
          isA<TwelveDataException>().having((e) => e.code, 'code', 429),
        ),
      );
    });

    test('lève une erreur typée sur une période sans données', () {
      expect(
        () => parseTimeSeries(_fixture('twelvedata_error_400_no_data.json')),
        throwsA(
          isA<TwelveDataException>().having((e) => e.code, 'code', 400),
        ),
      );
    });

    test('refuse une réponse sans points', () {
      expect(
        () => parseTimeSeries({'status': 'ok', 'values': <Object>[]}),
        throwsA(isA<TwelveDataException>()),
      );
    });
  });

  group('firstPointPerMonth', () {
    test('garde le premier jour de bourse de chaque mois', () {
      final daily = parseTimeSeries(
        _fixture('twelvedata_time_series_spy_1day_2020.json'),
      );
      final monthly = firstPointPerMonth(daily);
      expect(monthly.map((p) => p.date), [
        DateTime(2020, 2, 19),
        DateTime(2020, 3, 2),
        DateTime(2020, 4, 1),
      ]);
    });

    test('renvoie une liste vide pour une série vide', () {
      expect(firstPointPerMonth([]), isEmpty);
    });
  });

  test('encodeSeries produit un JSON valide et relisible', () {
    final json = jsonDecode(
      encodeSeries(
        id: 'spy_weekly',
        symbol: 'SPY',
        name: 'ETF S&P 500',
        frequency: 'weekly',
        points: [SeriesPoint(DateTime(2013, 1, 7), 147.07)],
      ),
    ) as Map<String, dynamic>;
    expect(json['adjusted'], isFalse);
    expect(json['points'], [
      {'date': '2013-01-07', 'close': 147.07},
    ]);
  });
}
