import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'src/series_transform.dart';

final snapshotEnd = DateTime(2026, 10, 19);
const outputDir = 'assets/data/series';
const delayBetweenRequests = Duration(seconds: 9);
const quotaResetDelay = Duration(seconds: 61);
const quotaExceededCode = 429;

enum Frequency {
  daily('1day'),
  weekly('1week'),
  firstTradingDayOfMonth('1day');

  const Frequency(this.apiInterval);

  final String apiInterval;
}

enum Source {
  twelveData('Twelve Data', 'USD'),
  fredTreasury10y('FRED DGS10, indice de rendement total calculé', 'INDEX');

  const Source(this.label, this.currency);

  final String label;
  final String currency;
}

class SeriesSpec {
  const SeriesSpec({
    required this.id,
    required this.symbol,
    required this.name,
    required this.frequency,
    required this.start,
    this.end,
    this.source = Source.twelveData,
  });

  final String id;
  final String symbol;
  final String name;
  final Frequency frequency;
  final String start;
  final String? end;
  final Source source;

  DateTime get endDate => end == null ? snapshotEnd : DateTime.parse(end!);
}

const specs = [
  SeriesSpec(
    id: 'spy_weekly',
    symbol: 'SPY',
    name: 'ETF S&P 500',
    frequency: Frequency.weekly,
    start: '1999-01-01',
  ),
  SeriesSpec(
    id: 'qqq_weekly',
    symbol: 'QQQ',
    name: 'ETF Nasdaq-100',
    frequency: Frequency.weekly,
    start: '1999-01-01',
  ),
  SeriesSpec(
    id: 'gold_weekly',
    symbol: 'XAU/USD',
    name: 'Or',
    frequency: Frequency.weekly,
    start: '1999-01-01',
  ),
  SeriesSpec(
    id: 'bonds_weekly',
    symbol: 'DGS10',
    name: "Obligations d'État américaines à 10 ans",
    frequency: Frequency.weekly,
    start: '1999-01-01',
    source: Source.fredTreasury10y,
  ),
  SeriesSpec(
    id: 'world_weekly',
    symbol: 'URTH',
    name: 'ETF MSCI World',
    frequency: Frequency.weekly,
    start: '2018-01-01',
  ),
  SeriesSpec(
    id: 'btc_weekly',
    symbol: 'BTC/USD',
    name: 'Bitcoin',
    frequency: Frequency.weekly,
    start: '2018-01-01',
  ),
  SeriesSpec(
    id: 'spy_monthly',
    symbol: 'SPY',
    name: 'ETF S&P 500',
    frequency: Frequency.firstTradingDayOfMonth,
    start: '2008-01-01',
  ),
  SeriesSpec(
    id: 'spy_daily_2008',
    symbol: 'SPY',
    name: 'ETF S&P 500',
    frequency: Frequency.daily,
    start: '2008-09-01',
    end: '2009-04-01',
  ),
  SeriesSpec(
    id: 'spy_daily_2020',
    symbol: 'SPY',
    name: 'ETF S&P 500',
    frequency: Frequency.daily,
    start: '2020-02-19',
    end: '2021-03-13',
  ),
];

Future<void> main(List<String> args) async {
  final selected = args.isEmpty
      ? specs
      : specs.where((spec) => args.contains(spec.id)).toList();
  final apiKey = _readApiKey();
  final client = http.Client();
  Directory(outputDir).createSync(recursive: true);
  try {
    for (final (index, spec) in selected.indexed) {
      if (index > 0 && spec.source == Source.twelveData) {
        await Future<void>.delayed(delayBetweenRequests);
      }
      final points = _pointsBefore(
        spec.endDate,
        await _download(client, spec, apiKey),
      );
      final series = switch (spec.frequency) {
        Frequency.firstTradingDayOfMonth => firstPointPerMonth(points),
        Frequency.daily || Frequency.weekly => points,
      };
      File('$outputDir/${spec.id}.json').writeAsStringSync(
        encodeSeries(
          id: spec.id,
          symbol: spec.symbol,
          name: spec.name,
          frequency: spec.frequency.name,
          source: spec.source.label,
          currency: spec.source.currency,
          points: series,
        ),
      );
      stdout.writeln(
        '${spec.id}: ${series.length} points, '
        '${formatDay(series.first.date)} → ${formatDay(series.last.date)}',
      );
    }
  } finally {
    client.close();
  }
}

List<SeriesPoint> _pointsBefore(DateTime end, List<SeriesPoint> points) =>
    points.where((p) => p.date.isBefore(end)).toList();

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

Future<List<SeriesPoint>> _download(
  http.Client client,
  SeriesSpec spec,
  String apiKey,
) => switch (spec.source) {
  Source.twelveData => _downloadTwelveData(client, spec, apiKey),
  Source.fredTreasury10y => _downloadFredBondIndex(client, spec),
};

Future<List<SeriesPoint>> _downloadTwelveData(
  http.Client client,
  SeriesSpec spec,
  String apiKey,
) async {
  try {
    return await _requestTwelveData(client, spec, apiKey);
  } on TwelveDataException catch (e) {
    if (e.code != quotaExceededCode) rethrow;
    stdout.writeln('${spec.id}: quota atteint, nouvel essai dans 61 s');
    await Future<void>.delayed(quotaResetDelay);
    return _requestTwelveData(client, spec, apiKey);
  }
}

Future<List<SeriesPoint>> _requestTwelveData(
  http.Client client,
  SeriesSpec spec,
  String apiKey,
) async {
  final uri = Uri.https('api.twelvedata.com', '/time_series', {
    'symbol': spec.symbol,
    'interval': spec.frequency.apiInterval,
    'start_date': spec.start,
    'end_date': formatDay(spec.endDate),
    'outputsize': '5000',
    'order': 'asc',
    'apikey': apiKey,
  });
  final response = await client.get(uri);
  return parseTimeSeries(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<List<SeriesPoint>> _downloadFredBondIndex(
  http.Client client,
  SeriesSpec spec,
) async {
  final uri = Uri.https('fred.stlouisfed.org', '/graph/fredgraph.csv', {
    'id': spec.symbol,
    'cosd': spec.start,
    'coed': formatDay(spec.endDate),
  });
  final response = await client.get(uri);
  final weeklyYields = lastPointPerWeek(
    _pointsBefore(spec.endDate, parseFredCsv(response.body)),
  );
  return bondTotalReturnIndex(weeklyYields);
}
