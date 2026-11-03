import 'dart:math';

import '../models/price_series.dart';
import 'calc/risk.dart';

const minimumGap = 0.05;
const comparisonStart = 2018;
const recentYears = 5;
const questionYears = [2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025];

class QuizAsset {
  final String id;
  final String name;
  final String category;

  const QuizAsset({
    required this.id,
    required this.name,
    required this.category,
  });
}

class ComparisonQuestion {
  final String question;
  final List<QuizAsset> choices;
  final int answerIndex;
  final String explanation;

  const ComparisonQuestion({
    required this.question,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
  });
}

class _Metric {
  final String question;
  final bool higherWins;
  final double? Function(PriceSeries series) measure;
  final String Function(String name, double value) describe;

  const _Metric({
    required this.question,
    required this.higherWins,
    required this.measure,
    required this.describe,
  });
}

String _percent(double value) {
  final sign = value > 0 ? '+' : (value < 0 ? '−' : '');
  final digits = (value.abs() * 100).toStringAsFixed(1).replaceAll('.', ',');
  return '$sign$digits %';
}

double? _performanceBetween(PriceSeries series, DateTime from, DateTime to) {
  final points = series.between(from, to).points;
  if (points.length < 2 || points.first.date.year != from.year) return null;
  return points.last.close / points.first.close - 1;
}

double? _yearPerformance(PriceSeries series, int year) {
  final yearEnd = DateTime(year, 12, 31);
  if (series.lastDate.isBefore(yearEnd)) return null;
  return _performanceBetween(series, DateTime(year), yearEnd);
}

List<double>? _closesSince2018(PriceSeries series) {
  final startsLate = series.firstDate.isAfter(DateTime(comparisonStart, 1, 8));
  if (startsLate) return null;
  return series
      .between(DateTime(comparisonStart), null)
      .points
      .map((point) => point.close)
      .toList();
}

double? _volatilitySince2018(PriceSeries series) {
  final closes = _closesSince2018(series);
  return closes == null
      ? null
      : annualizedVolatility(returnsFromPrices(closes));
}

double? _drawdownSince2018(PriceSeries series) {
  final closes = _closesSince2018(series);
  return closes == null ? null : maxDrawdown(closes).percent;
}

double? _recentPerformance(PriceSeries series) {
  final points = series.lastMonths(recentYears * 12).points;
  if (points.length < 2) return null;
  return points.last.close / points.first.close - 1;
}

List<_Metric> _metrics() {
  return [
    _Metric(
      question: "Lequel bouge le plus d'une semaine à l'autre ?",
      higherWins: true,
      measure: _volatilitySince2018,
      describe: (name, value) =>
          '$name : volatilité de ${_percent(value).replaceAll('+', '')} par an',
    ),
    _Metric(
      question: 'Lequel a connu la pire chute depuis 2018 ?',
      higherWins: false,
      measure: _drawdownSince2018,
      describe: (name, value) => '$name : pire baisse de ${_percent(value)}',
    ),
    _Metric(
      question: 'Lequel a le plus monté sur les 5 dernières années ?',
      higherWins: true,
      measure: _recentPerformance,
      describe: (name, value) => '$name : ${_percent(value)} en 5 ans',
    ),
    for (final year in questionYears) ...[
      _Metric(
        question: 'Lequel a le plus monté en $year ?',
        higherWins: true,
        measure: (series) => _yearPerformance(series, year),
        describe: (name, value) => '$name : ${_percent(value)} en $year',
      ),
      _Metric(
        question: 'Lequel a le plus baissé en $year ?',
        higherWins: false,
        measure: (series) {
          final performance = _yearPerformance(series, year);
          return performance != null && performance < 0 ? performance : null;
        },
        describe: (name, value) => '$name : ${_percent(value)} en $year',
      ),
    ],
  ];
}

List<ComparisonQuestion> generateQuestions(
  Map<QuizAsset, PriceSeries> seriesByAsset,
  Random random,
) {
  final assets = seriesByAsset.keys.toList();
  final questions = <ComparisonQuestion>[];
  for (final metric in _metrics()) {
    for (var i = 0; i < assets.length; i++) {
      for (var j = i + 1; j < assets.length; j++) {
        final first = assets[i];
        final second = assets[j];
        final firstValue = metric.measure(seriesByAsset[first]!);
        final secondValue = metric.measure(seriesByAsset[second]!);
        if (firstValue == null || secondValue == null) continue;
        if ((firstValue - secondValue).abs() < minimumGap) continue;
        final firstWins = metric.higherWins
            ? firstValue > secondValue
            : firstValue < secondValue;
        final isSwapped = random.nextBool();
        questions.add(
          ComparisonQuestion(
            question: metric.question,
            choices: isSwapped ? [second, first] : [first, second],
            answerIndex: firstWins == isSwapped ? 1 : 0,
            explanation:
                '${metric.describe(first.name, firstValue)}. '
                '${metric.describe(second.name, secondValue)}.',
          ),
        );
      }
    }
  }
  return questions;
}
