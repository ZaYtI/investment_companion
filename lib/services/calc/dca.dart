import '../../models/price_point.dart';
import 'invalid_input_exception.dart';

const minDcaDeposits = 3;

class DcaStep {
  final DateTime date;
  final double price;
  final double sharesBought;
  final double totalShares;
  final double invested;
  final double value;

  const DcaStep({
    required this.date,
    required this.price,
    required this.sharesBought,
    required this.totalShares,
    required this.invested,
    required this.value,
  });
}

class DcaResult {
  final List<DcaStep> steps;
  final double finalPrice;

  const DcaResult({required this.steps, required this.finalPrice});

  double get totalShares => steps.last.totalShares;
  double get invested => steps.last.invested;
  double get averageCost => invested / totalShares;
  double get finalValue => totalShares * finalPrice;
  double get gain => finalValue - invested;
  double get performance => finalValue / invested - 1;
}

DcaResult monthlyInvestment(
  List<PricePoint> monthlyPrices, {
  required double amount,
  double? finalPrice,
  int minDeposits = minDcaDeposits,
}) {
  if (amount <= 0) {
    throw const InvalidInputException('Le versement doit être positif.');
  }
  if (monthlyPrices.isEmpty || monthlyPrices.length < minDeposits) {
    throw const InvalidInputException(
      'Il faut au moins 3 versements. Reculez la date de début.',
    );
  }
  final steps = <DcaStep>[];
  var totalShares = 0.0;
  var invested = 0.0;
  for (final point in monthlyPrices) {
    if (point.close <= 0) {
      throw const InvalidInputException('Le prix doit être positif.');
    }
    final sharesBought = amount / point.close;
    totalShares += sharesBought;
    invested += amount;
    steps.add(
      DcaStep(
        date: point.date,
        price: point.close,
        sharesBought: sharesBought,
        totalShares: totalShares,
        invested: invested,
        value: totalShares * point.close,
      ),
    );
  }
  return DcaResult(
    steps: steps,
    finalPrice: finalPrice ?? monthlyPrices.last.close,
  );
}

class MonthlyPrices {
  final List<PricePoint> prices;
  final List<DateTime> skippedMonths;

  const MonthlyPrices({required this.prices, required this.skippedMonths});
}

MonthlyPrices firstPriceOfEachMonth(
  List<PricePoint> prices, {
  required DateTime from,
  required DateTime to,
}) {
  final result = <PricePoint>[];
  final skipped = <DateTime>[];
  var month = DateTime(from.year, from.month);
  final lastMonth = DateTime(to.year, to.month);
  while (!month.isAfter(lastMonth)) {
    final firstOfMonth = prices
        .where((p) => p.date.year == month.year && p.date.month == month.month)
        .firstOrNull;
    if (firstOfMonth == null) {
      skipped.add(month);
    } else {
      result.add(firstOfMonth);
    }
    month = DateTime(month.year, month.month + 1);
  }
  return MonthlyPrices(prices: result, skippedMonths: skipped);
}
