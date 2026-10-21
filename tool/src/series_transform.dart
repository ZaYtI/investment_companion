/// Transformations pures des réponses Twelve Data en séries embarquées.
///
/// Aucun accès réseau ni fichier ici : ces fonctions sont testées dans
/// `test/tool/series_transform_test.dart`.
library;

/// Un point de série : la date (sans heure) et le cours de clôture.
class SeriesPoint {
  const SeriesPoint(this.date, this.close);

  final DateTime date;
  final double close;
}

/// Erreur renvoyée par l'API (`"status": "error"`) ou réponse inattendue.
class TwelveDataException implements Exception {
  const TwelveDataException(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'TwelveDataException($code): $message';
}

/// Lit les points d'une réponse `time_series`.
///
/// Twelve Data renvoie les cours en chaînes (`"close": "147.07"`) et, par
/// défaut, du plus récent au plus ancien : le résultat est trié par date
/// croissante quel que soit l'ordre reçu.
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
  final points = [
    for (final value in values.cast<Map<String, dynamic>>())
      SeriesPoint(
        DateTime.parse(value['datetime'] as String),
        double.parse(value['close'] as String),
      ),
  ]..sort((a, b) => a.date.compareTo(b.date));
  return points;
}

/// Garde le premier point de chaque mois : la clôture du premier jour de
/// bourse, utilisée par l'investissement mensuel (chapitre 4).
///
/// Attend une série quotidienne triée par date croissante.
List<SeriesPoint> firstPointPerMonth(List<SeriesPoint> daily) {
  final result = <SeriesPoint>[];
  for (final point in daily) {
    final last = result.isEmpty ? null : result.last;
    if (last == null ||
        last.date.year != point.date.year ||
        last.date.month != point.date.month) {
      result.add(point);
    }
  }
  return result;
}

/// Écrit une série au format embarqué, un point par ligne pour des diffs
/// lisibles.
String encodeSeries({
  required String id,
  required String symbol,
  required String name,
  required String frequency,
  required List<SeriesPoint> points,
}) {
  String day(DateTime date) => date.toIso8601String().substring(0, 10);
  final lines = [
    for (final p in points) '    {"date": "${day(p.date)}", "close": ${p.close}}',
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
