/// Télécharge les séries de prix embarquées dans l'application.
///
/// Usage, depuis la racine du projet (clé lue dans `env.json`) :
///   dart run tool/fetch_series.dart
///
/// Les dates sont figées (voir [snapshotEnd]) : relancé, le script régénère
/// exactement les mêmes fichiers. Pour rafraîchir les données, avancer
/// [snapshotEnd] puis relancer.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'src/series_transform.dart';

/// Fin de l'instantané, exclusive pour l'API : le dernier point est la
/// semaine du 12 octobre 2026, la dernière semaine complète.
const snapshotEnd = '2026-10-19';

const outputDir = 'assets/data/series';

/// Pause entre deux appels : le plan gratuit autorise 8 requêtes par minute.
const pauseBetweenCalls = Duration(seconds: 9);

class SeriesSpec {
  const SeriesSpec({
    required this.id,
    required this.symbol,
    required this.name,
    required this.interval,
    required this.start,
    this.firstOfMonth = false,
  });

  final String id;
  final String symbol;
  final String name;
  final String interval;
  final String start;

  /// Télécharge en quotidien et ne garde que le premier jour de bourse de
  /// chaque mois (l'intervalle `1month` de l'API donne la clôture de fin de
  /// mois).
  final bool firstOfMonth;

  String get frequency => firstOfMonth ? 'monthly_first_day' : 'weekly';
}

/// Une série par actif et par fréquence ; chaque chapitre lit la période
/// dont il a besoin :
/// - ch.1 Les bases : 5 dernières années de SPY, or, ETF monde ;
/// - ch.2 Le risque : SPY, or, bitcoin depuis 2018 ;
/// - ch.3 Les baisses : SPY 2007 à 2013 ;
/// - ch.4 Investir chaque mois : SPY mensuel, dates de début de 2015 à
///   aujourd'hui.
const specs = [
  SeriesSpec(
    id: 'spy_weekly',
    symbol: 'SPY',
    name: 'ETF S&P 500',
    interval: '1week',
    start: '2007-01-01',
  ),
  SeriesSpec(
    id: 'gold_weekly',
    symbol: 'XAU/USD',
    name: 'Or',
    interval: '1week',
    start: '2018-01-01',
  ),
  SeriesSpec(
    id: 'world_weekly',
    symbol: 'URTH',
    name: 'ETF MSCI World',
    interval: '1week',
    start: '2018-01-01',
  ),
  SeriesSpec(
    id: 'btc_weekly',
    symbol: 'BTC/USD',
    name: 'Bitcoin',
    interval: '1week',
    start: '2018-01-01',
  ),
  SeriesSpec(
    id: 'spy_monthly',
    symbol: 'SPY',
    name: 'ETF S&P 500',
    interval: '1day',
    start: '2015-01-01',
    firstOfMonth: true,
  ),
];

Future<void> main() async {
  final apiKey = _readApiKey();
  final client = http.Client();
  Directory(outputDir).createSync(recursive: true);
  try {
    for (final (index, spec) in specs.indexed) {
      if (index > 0) await Future<void>.delayed(pauseBetweenCalls);
      // Le bitcoin cote 7 jours sur 7 : l'API peut renvoyer la semaine en
      // cours, qui commence à snapshotEnd. On ne garde que les points
      // antérieurs pour rester reproductible.
      var points = (await _fetch(client, spec, apiKey))
          .where((p) => p.date.isBefore(DateTime.parse(snapshotEnd)))
          .toList();
      if (spec.firstOfMonth) points = firstPointPerMonth(points);
      final file = File('$outputDir/${spec.id}.json');
      file.writeAsStringSync(
        encodeSeries(
          id: spec.id,
          symbol: spec.symbol,
          name: spec.name,
          frequency: spec.frequency,
          points: points,
        ),
      );
      stdout.writeln(
        '${spec.id}: ${points.length} points, '
        '${points.first.date.toIso8601String().substring(0, 10)} → '
        '${points.last.date.toIso8601String().substring(0, 10)}',
      );
    }
  } finally {
    client.close();
  }
}

String _readApiKey() {
  final file = File('env.json');
  if (!file.existsSync()) {
    stderr.writeln('env.json introuvable : cp env.example.json env.json');
    exit(1);
  }
  final key = (jsonDecode(file.readAsStringSync()) as Map)['TWELVE_DATA_KEY'];
  if (key is! String || key.isEmpty) {
    stderr.writeln('TWELVE_DATA_KEY vide dans env.json');
    exit(1);
  }
  return key;
}

Future<List<SeriesPoint>> _fetch(
  http.Client client,
  SeriesSpec spec,
  String apiKey,
) async {
  final uri = Uri.https('api.twelvedata.com', '/time_series', {
    'symbol': spec.symbol,
    'interval': spec.interval,
    'start_date': spec.start,
    'end_date': snapshotEnd,
    'outputsize': '5000',
    'order': 'asc',
    'apikey': apiKey,
  });
  for (var attempt = 1; ; attempt++) {
    final response = await client.get(uri);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    try {
      return parseTimeSeries(json);
    } on TwelveDataException catch (e) {
      // Quota de la minute épuisé : on attend la minute suivante, une fois.
      if (e.code == 429 && attempt == 1) {
        stdout.writeln('${spec.id}: quota atteint, nouvel essai dans 61 s');
        await Future<void>.delayed(const Duration(seconds: 61));
        continue;
      }
      rethrow;
    }
  }
}
