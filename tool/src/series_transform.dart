import 'dart:math';

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

DateTime mondayOf(DateTime date) => DateTime(
  date.year,
  date.month,
  date.day - (date.weekday - DateTime.monday),
);

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

List<SeriesPoint> parseFredCsv(String csv) => [
  for (final line in csv.trim().split('\n').skip(1))
    if (double.tryParse(line.split(',')[1]) case final value?)
      SeriesPoint(DateTime.parse(line.split(',')[0]), value),
];

List<SeriesPoint> lastPointPerWeek(List<SeriesPoint> daily) {
  final byWeek = <DateTime, double>{};
  for (final point in daily) {
    byWeek[mondayOf(point.date)] = point.close;
  }
  return [
    for (final MapEntry(:key, :value) in byWeek.entries)
      SeriesPoint(key, value),
  ];
}

const bondMaturityYears = 10;
const couponsPerYear = 2;
const weeksPerYear = 52;
const bondIndexBase = 100.0;

double parBondPrice({required double coupon, required double yield}) {
  const periods = bondMaturityYears * couponsPerYear;
  final periodYield = yield / couponsPerYear;
  final periodCoupon = coupon / couponsPerYear;
  if (periodYield == 0) return 1 + periodCoupon * periods;
  final discount = 1 / pow(1 + periodYield, periods);
  return periodCoupon / periodYield * (1 - discount) + discount;
}

List<SeriesPoint> bondTotalReturnIndex(
  List<SeriesPoint> weeklyYieldsInPercent,
) {
  if (weeklyYieldsInPercent.isEmpty) return [];
  var value = bondIndexBase;
  final index = [SeriesPoint(weeklyYieldsInPercent.first.date, value)];
  for (var i = 1; i < weeklyYieldsInPercent.length; i++) {
    final previousYield = weeklyYieldsInPercent[i - 1].close / 100;
    final currentYield = weeklyYieldsInPercent[i].close / 100;
    final price = parBondPrice(coupon: previousYield, yield: currentYield);
    value *= price + previousYield / weeksPerYear;
    index.add(SeriesPoint(weeklyYieldsInPercent[i].date, _round4(value)));
  }
  return index;
}

double _round4(double value) => (value * 10000).round() / 10000;

String encodeSeries({
  required String id,
  required String symbol,
  required String name,
  required String frequency,
  required String source,
  required String currency,
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
      '  "source": "$source",\n'
      '  "adjusted": false,\n'
      '  "currency": "$currency",\n'
      '  "points": [\n'
      '${lines.join(',\n')}\n'
      '  ]\n'
      '}\n';
}
