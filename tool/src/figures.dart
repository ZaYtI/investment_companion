import 'dart:math';

import 'series_transform.dart';

class Drawdown {
  const Drawdown({
    required this.peak,
    required this.trough,
    required this.recovery,
  });

  final SeriesPoint peak;
  final SeriesPoint trough;
  final SeriesPoint? recovery;

  double get percent => trough.close / peak.close - 1;
  double get requiredGain => peak.close / trough.close - 1;
}

class DcaResult {
  const DcaResult({
    required this.invested,
    required this.shares,
    required this.value,
    required this.deposits,
  });

  final double invested;
  final double shares;
  final double value;
  final int deposits;

  double get performance => value / invested - 1;
  double get averageCost => invested / shares;
}

List<SeriesPoint> between(
  List<SeriesPoint> points,
  DateTime from,
  DateTime to,
) =>
    points.where((p) => !p.date.isBefore(from) && !p.date.isAfter(to)).toList();

SeriesPoint closestOnOrAfter(List<SeriesPoint> points, DateTime date) =>
    points.firstWhere((p) => !p.date.isBefore(date));

double change(double from, double to) => to / from - 1;

Drawdown maxDrawdown(List<SeriesPoint> points, {List<SeriesPoint>? after}) {
  var runningPeak = points.first;
  var worst = (peak: points.first, trough: points.first);
  for (final point in points) {
    if (point.close > runningPeak.close) runningPeak = point;
    if (point.close / runningPeak.close <
        worst.trough.close / worst.peak.close) {
      worst = (peak: runningPeak, trough: point);
    }
  }
  final recovery = (after ?? points)
      .where(
        (p) => p.date.isAfter(worst.trough.date) && p.close >= worst.peak.close,
      )
      .firstOrNull;
  return Drawdown(peak: worst.peak, trough: worst.trough, recovery: recovery);
}

List<double> periodReturns(List<SeriesPoint> points) => [
  for (var i = 1; i < points.length; i++)
    points[i].close / points[i - 1].close - 1,
];

double sampleStandardDeviation(List<double> values) {
  final mean = values.reduce((a, b) => a + b) / values.length;
  final squares = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);
  return sqrt(squares / (values.length - 1));
}

const weeksPerYear = 52;

double annualizedWeeklyVolatility(List<SeriesPoint> weekly) =>
    sampleStandardDeviation(periodReturns(weekly)) * sqrt(weeksPerYear);

DcaResult monthlyInvestment(
  List<SeriesPoint> monthly, {
  required double amount,
  required DateTime from,
  required DateTime to,
  required double finalPrice,
}) {
  final deposits = between(monthly, from, to);
  final shares = deposits.fold(0.0, (sum, p) => sum + amount / p.close);
  return DcaResult(
    invested: amount * deposits.length,
    shares: shares,
    value: shares * finalPrice,
    deposits: deposits.length,
  );
}

List<SeriesPoint> buyAndHoldPortfolio(
  Map<List<SeriesPoint>, double> weightsBySeries, {
  required DateTime from,
  required DateTime to,
  double capital = 10000,
}) {
  final aligned = {
    for (final MapEntry(key: series, value: weight) in weightsBySeries.entries)
      if (weight > 0) between(series, from, to): weight,
  };
  final dates = aligned.keys.first.map((p) => p.date).toList();
  final shares = {
    for (final MapEntry(key: series, value: weight) in aligned.entries)
      series: capital * weight / series.first.close,
  };
  return [
    for (final date in dates)
      SeriesPoint(
        date,
        aligned.keys.fold(
          0.0,
          (sum, series) =>
              sum + shares[series]! * _closeOnOrBefore(series, date),
        ),
      ),
  ];
}

double _closeOnOrBefore(List<SeriesPoint> series, DateTime date) =>
    series.lastWhere((p) => !p.date.isAfter(date)).close;
