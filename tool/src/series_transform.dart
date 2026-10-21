class SeriesPoint {
  const SeriesPoint(this.date, this.close);

  final DateTime date;
  final double close;
}

class TwelveDataException implements Exception {
  const TwelveDataException(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'TwelveDataException($code): $message';
}

String formatDay(DateTime date) => date.toIso8601String().substring(0, 10);

List<SeriesPoint> parseTimeSeries(Map<String, dynamic> json) {
  if (json['status'] == 'error') {
    throw TwelveDataException(
      json['code'] as int? ?? 0,
      json['message'] as String? ?? 'Erreur inconnue',
    );
  }
  final values = json['values'];
  if (values is! List || values.isEmpty) {
    throw const TwelveDataException(0, 'Réponse sans points');
  }
  return [
    for (final value in values.cast<Map<String, dynamic>>())
      SeriesPoint(
        DateTime.parse(value['datetime'] as String),
        double.parse(value['close'] as String),
      ),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

List<SeriesPoint> firstPointPerMonth(List<SeriesPoint> daily) {
  final result = <SeriesPoint>[];
  for (final point in daily) {
    final previous = result.isEmpty ? null : result.last.date;
    if (previous == null ||
        previous.year != point.date.year ||
        previous.month != point.date.month) {
      result.add(point);
    }
  }
  return result;
}

String encodeSeries({
  required String id,
  required String symbol,
  required String name,
  required String frequency,
  required List<SeriesPoint> points,
}) {
  final lines = [
    for (final p in points)
      '    {"date": "${formatDay(p.date)}", "close": ${p.close}}',
  ];
  return '{\n'
      '  "id": "$id",\n'
      '  "symbol": "$symbol",\n'
      '  "name": "$name",\n'
      '  "frequency": "$frequency",\n'
      '  "source": "Twelve Data",\n'
      '  "adjusted": false,\n'
      '  "currency": "USD",\n'
      '  "points": [\n'
      '${lines.join(',\n')}\n'
      '  ]\n'
      '}\n';
}
