import '../../models/price_point.dart';
import 'invalid_input_exception.dart';
import 'risk.dart';

const cashId = 'cash';
const weightsTolerance = 0.0001;

class PortfolioResult {
  final double capital;
  final List<DateTime> dates;
  final Map<String, double> shares;
  final Map<String, List<double>> prices;
  final List<double> values;

  const PortfolioResult({
    required this.capital,
    required this.dates,
    required this.shares,
    required this.prices,
    required this.values,
  });

  double get finalValue => values.last;
  double get performance => finalValue / capital - 1;
  Drawdown get drawdown => maxDrawdown(values);

  Map<String, double> weightsAt(int index) {
    return {
      for (final id in shares.keys)
        id: shares[id]! * prices[id]![index] / values[index],
    };
  }
}

List<double> alignOnDates(List<PricePoint> series, List<DateTime> dates) {
  final aligned = <double>[];
  var cursor = 0;
  double? lastClose;
  for (final date in dates) {
    while (cursor < series.length && !series[cursor].date.isAfter(date)) {
      lastClose = series[cursor].close;
      cursor++;
    }
    if (lastClose == null) {
      throw InvalidInputException(
        'Aucun cours avant le ${date.toIso8601String()}.',
      );
    }
    aligned.add(lastClose);
  }
  return aligned;
}

PortfolioResult buyAndHold({
  required double capital,
  required Map<String, double> weights,
  required Map<String, List<double>> prices,
  required List<DateTime> dates,
}) {
  if (capital <= 0) {
    throw const InvalidInputException('Le capital doit être positif.');
  }
  final totalWeight = weights.values.fold(0.0, (sum, weight) => sum + weight);
  if ((totalWeight - 1).abs() > weightsTolerance) {
    throw const InvalidInputException('Les pondérations doivent faire 100 %.');
  }
  final usedPrices = <String, List<double>>{};
  final shares = <String, double>{};
  for (final id in weights.keys) {
    final weight = weights[id]!;
    if (weight < 0) {
      throw const InvalidInputException('Une pondération est négative.');
    }
    if (weight == 0) continue;
    final assetPrices = id == cashId
        ? List.filled(dates.length, 1.0)
        : prices[id]!;
    if (assetPrices.length != dates.length) {
      throw const InvalidInputException('Les séries ne sont pas alignées.');
    }
    usedPrices[id] = assetPrices;
    shares[id] = capital * weight / assetPrices.first;
  }
  final values = <double>[];
  for (var i = 0; i < dates.length; i++) {
    var value = 0.0;
    for (final id in shares.keys) {
      value += shares[id]! * usedPrices[id]![i];
    }
    values.add(value);
  }
  return PortfolioResult(
    capital: capital,
    dates: dates,
    shares: shares,
    prices: usedPrices,
    values: values,
  );
}
