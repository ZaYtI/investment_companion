import 'price_point.dart';

enum SeriesFrequency { daily, weekly, monthly }

class PriceSeries {
  final String id;
  final String symbol;
  final String name;
  final SeriesFrequency frequency;
  final List<PricePoint> points;

  const PriceSeries({
    required this.id,
    required this.symbol,
    required this.name,
    required this.frequency,
    required this.points,
  });

  factory PriceSeries.fromJson(Map<String, dynamic> json) {
    final points = (json['points'] as List<dynamic>)
        .map((point) => PricePoint.fromJson(point as Map<String, dynamic>))
        .toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return PriceSeries(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      frequency: switch (json['frequency'] as String) {
        'daily' => SeriesFrequency.daily,
        'weekly' => SeriesFrequency.weekly,
        _ => SeriesFrequency.monthly,
      },
      points: points,
    );
  }

  DateTime get firstDate => points.first.date;
  DateTime get lastDate => points.last.date;

  int get periodsPerYear => switch (frequency) {
    SeriesFrequency.daily => 252,
    SeriesFrequency.weekly => 52,
    SeriesFrequency.monthly => 12,
  };

  PriceSeries withPoints(List<PricePoint> newPoints) {
    return PriceSeries(
      id: id,
      symbol: symbol,
      name: name,
      frequency: frequency,
      points: newPoints,
    );
  }

  PriceSeries lastMonths(int months) {
    final start = DateTime(
      lastDate.year,
      lastDate.month - months,
      lastDate.day,
    );
    return between(start, null);
  }

  PriceSeries between(DateTime? from, DateTime? to) {
    return withPoints(
      points
          .where(
            (point) =>
                (from == null || !point.date.isBefore(from)) &&
                (to == null || !point.date.isAfter(to)),
          )
          .toList(),
    );
  }
}
