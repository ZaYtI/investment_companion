import 'dart:math';

import 'invalid_input_exception.dart';
import 'performance.dart';

const weeksPerYear = 52;
const minVolatilityPoints = 8;

class Drawdown {
  final double percent;
  final int peakIndex;
  final int troughIndex;

  const Drawdown({
    required this.percent,
    required this.peakIndex,
    required this.troughIndex,
  });

  bool get hasDrop => percent < 0;
}

List<double> returnsFromPrices(List<double> prices) {
  final returns = <double>[];
  for (var i = 1; i < prices.length; i++) {
    returns.add(variation(prices[i - 1], prices[i]));
  }
  return returns;
}

double sampleStdDev(
  List<double> values, {
  int minPoints = minVolatilityPoints,
}) {
  if (values.length < minPoints || values.length < 2) {
    throw const InvalidInputException('Pas assez de points pour mesurer.');
  }
  final mean = values.reduce((a, b) => a + b) / values.length;
  var sumOfSquares = 0.0;
  for (final value in values) {
    sumOfSquares += (value - mean) * (value - mean);
  }
  return sqrt(sumOfSquares / (values.length - 1));
}

double annualizedVolatility(
  List<double> weeklyReturns, {
  int minPoints = minVolatilityPoints,
}) {
  return sampleStdDev(weeklyReturns, minPoints: minPoints) * sqrt(weeksPerYear);
}

Drawdown maxDrawdown(List<double> values) {
  if (values.length < 2) {
    throw const InvalidInputException('Il faut au moins deux valeurs.');
  }
  if (values.any((value) => value <= 0)) {
    throw const InvalidInputException('Les valeurs doivent être positives.');
  }
  var peakIndex = 0;
  var worst = const Drawdown(percent: 0, peakIndex: 0, troughIndex: 0);
  for (var i = 1; i < values.length; i++) {
    if (values[i] > values[peakIndex]) {
      peakIndex = i;
    }
    final drop = values[i] / values[peakIndex] - 1;
    if (drop < worst.percent) {
      worst = Drawdown(percent: drop, peakIndex: peakIndex, troughIndex: i);
    }
  }
  return worst;
}

double requiredGain(double drawdown) {
  if (drawdown <= -1) {
    throw const InvalidInputException('Une perte totale ne se rattrape pas.');
  }
  return 1 / (1 + drawdown) - 1;
}
