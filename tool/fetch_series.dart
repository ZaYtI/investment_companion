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
  weekly('1week'),
  firstTradingDayOfMonth('1day');

  const Frequency(this.apiInterval);

  final String apiInterval;
}

class SeriesSpec {
  const SeriesSpec({
    required this.id,
    required this.symbol,
    required this.name,
    required this.frequency,
    required this.start,
  });

  final String id;
  final String symbol;
  final String name;
  final Frequency frequency;
  final String start;
}

const specs = [
  SeriesSpec(
    id: 'spy_weekly',
    symbol: 'SPY',
    name: 'ETF S&P 500',
    frequency: Frequency.weekly,
    start: '2007-01-01',
  ),
  SeriesSpec(
    id: 'gold_weekly',
    symbol: 'XAU/USD',
    name: 'Or',
    frequency: Frequency.weekly,
    start: '2018-01-01',
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
    start: '2015-01-01',
  ),
];

Future<void> main() async {
  final apiKey = _readApiKey();
  final client = http.Client();
  Directory(outputDir).createSync(recursive: true);
  try {
    for (final (index, spec) in specs.indexed) {
      if (index > 0) await Future<void>.delayed(delayBetweenRequests);
      final points = _completedPoints(await _download(client, spec, apiKey));
      final series = spec.frequency == Frequency.firstTradingDayOfMonth
          ? firstPointPerMonth(points)
          : points;
      File('$outputDir/${spec.id}.json').writeAsStringSync(
        encodeSeries(
          id: spec.id,
          symbol: spec.symbol,
          name: spec.name,
          frequency: spec.frequency.name,
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

List<SeriesPoint> _completedPoints(List<SeriesPoint> points) =>
    points.where((p) => p.date.isBefore(snapshotEnd)).toList();

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
) async {
  try {
    return await _request(client, spec, apiKey);
  } on TwelveDataException catch (e) {
    if (e.code != quotaExceededCode) rethrow;
    stdout.writeln('${spec.id}: quota atteint, nouvel essai dans 61 s');
    await Future<void>.delayed(quotaResetDelay);
    return _request(client, spec, apiKey);
  }
}

Future<List<SeriesPoint>> _request(
  http.Client client,
  SeriesSpec spec,
  String apiKey,
) async {
  final uri = Uri.https('api.twelvedata.com', '/time_series', {
    'symbol': spec.symbol,
    'interval': spec.frequency.apiInterval,
    'start_date': spec.start,
    'end_date': formatDay(snapshotEnd),
    'outputsize': '5000',
    'order': 'asc',
    'apikey': apiKey,
  });
  final response = await client.get(uri);
  return parseTimeSeries(jsonDecode(response.body) as Map<String, dynamic>);
}
