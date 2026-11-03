import '../data/price_repository.dart';
import '../models/price_point.dart';
import '../models/price_series.dart';
import '../models/simulation_result.dart';
import 'calc/dca.dart';
import 'calc/invalid_input_exception.dart';
import 'calc/portfolio.dart';
import 'calc/risk.dart';

enum SimulationMode { lumpSum, monthly }

class HistoryTooShortException implements Exception {
  final String assetId;
  final DateTime earliestDate;

  const HistoryTooShortException(this.assetId, this.earliestDate);
}

class DcaSimulation {
  final DcaResult dca;
  final PricePoint lastPrice;
  final double lumpSumShares;

  const DcaSimulation({
    required this.dca,
    required this.lastPrice,
    required this.lumpSumShares,
  });

  double get lumpSumFinalValue => lumpSumShares * lastPrice.close;
}

class SimulationService {
  final PriceRepository repository;

  SimulationService(this.repository);

  static final keyDates = {
    'Bulle internet': DateTime(2000, 3, 6),
    'Faillite de Lehman': DateTime(2008, 9, 15),
    'Covid': DateTime(2020, 3, 23),
    'Hausse des taux': DateTime(2022, 1, 3),
  };

  Future<SimulationResult> simulate({
    required Map<String, double> weights,
    required DateTime start,
    DateTime? end,
    SimulationMode mode = SimulationMode.lumpSum,
    required double amount,
  }) async {
    final series = await _loadSeries(weights, start, end);
    return switch (mode) {
      SimulationMode.lumpSum => _lumpSum(weights, series, amount),
      SimulationMode.monthly => _monthly(weights, series, amount, start, end),
    };
  }

  Future<DcaSimulation> simulateDca({
    required String monthlyAssetId,
    required String lastPriceAssetId,
    required DateTime start,
    required double monthlyAmount,
  }) async {
    final monthlySeries = await repository.getSeries(monthlyAssetId);
    final lastPriceSeries = await repository.getSeries(lastPriceAssetId);
    if (monthlySeries.firstDate.isAfter(start)) {
      throw HistoryTooShortException(monthlyAssetId, monthlySeries.firstDate);
    }
    final lastPrice = lastPriceSeries.points.last;
    final monthlyPrices = firstPriceOfEachMonth(
      monthlySeries.points,
      from: start,
      to: lastPrice.date,
    );
    final dca = monthlyInvestment(
      monthlyPrices.prices,
      amount: monthlyAmount,
      finalPrice: lastPrice.close,
    );
    return DcaSimulation(
      dca: dca,
      lastPrice: lastPrice,
      lumpSumShares: dca.invested / dca.steps.first.price,
    );
  }

  Future<Map<String, PriceSeries>> _loadSeries(
    Map<String, double> weights,
    DateTime start,
    DateTime? end,
  ) async {
    final series = <String, PriceSeries>{};
    for (final id in weights.keys) {
      if (id == cashId || weights[id] == 0) continue;
      final full = await repository.getSeries(id);
      if (full.firstDate.isAfter(start)) {
        throw HistoryTooShortException(id, full.firstDate);
      }
      series[id] = full;
    }
    if (series.isEmpty) {
      throw const InvalidInputException('Choisissez au moins un actif.');
    }
    return {
      for (final id in series.keys)
        id: series[id]!.between(
          series[id]!.points.lastWhere((p) => !p.date.isAfter(start)).date,
          end,
        ),
    };
  }

  SimulationResult _lumpSum(
    Map<String, double> weights,
    Map<String, PriceSeries> series,
    double capital,
  ) {
    final reference = series.values.first;
    final dates = reference.points.map((point) => point.date).toList();
    final portfolio = buyAndHold(
      capital: capital,
      weights: weights,
      prices: {
        for (final id in series.keys)
          id: alignOnDates(series[id]!.points, dates),
      },
      dates: dates,
    );
    final returns = returnsFromPrices(portfolio.values);
    return SimulationResult(
      dates: dates,
      values: portfolio.values,
      invested: List.filled(dates.length, capital),
      maxDrawdown: portfolio.drawdown.percent,
      volatility: returns.length < minVolatilityPoints
          ? null
          : annualizedVolatility(
              returns,
              periodsPerYear: reference.periodsPerYear,
            ),
      keyDates: _keyDateValues(dates, portfolio.values),
    );
  }

  SimulationResult _monthly(
    Map<String, double> weights,
    Map<String, PriceSeries> series,
    double monthlyAmount,
    DateTime start,
    DateTime? end,
  ) {
    final lastDate = end ?? series.values.first.lastDate;
    final dcaByAsset = <String, DcaResult>{};
    for (final id in series.keys) {
      final monthlyPrices = firstPriceOfEachMonth(
        series[id]!.points,
        from: start,
        to: lastDate,
      );
      dcaByAsset[id] = monthlyInvestment(
        monthlyPrices.prices,
        amount: monthlyAmount * weights[id]!,
        finalPrice: series[id]!.points.last.close,
      );
    }
    final cashShare = weights[cashId] ?? 0;
    final reference = dcaByAsset.values.first.steps;
    final dates = <DateTime>[];
    final values = <double>[];
    final invested = <double>[];
    for (var i = 0; i < reference.length; i++) {
      final paidSoFar = monthlyAmount * (i + 1);
      var value = paidSoFar * cashShare;
      for (final dca in dcaByAsset.values) {
        value += dca.steps[i].value;
      }
      dates.add(reference[i].date);
      values.add(value);
      invested.add(paidSoFar);
    }
    return SimulationResult(
      dates: dates,
      values: values,
      invested: invested,
      maxDrawdown: maxDrawdown(values).percent,
      volatility: null,
      keyDates: _keyDateValues(dates, values),
    );
  }

  List<KeyDateValue> _keyDateValues(List<DateTime> dates, List<double> values) {
    final result = <KeyDateValue>[];
    for (final entry in keyDates.entries) {
      final index = dates.indexWhere((date) => !date.isBefore(entry.value));
      if (index <= 0) continue;
      result.add(
        KeyDateValue(
          label: entry.key,
          date: dates[index],
          value: values[index],
        ),
      );
    }
    return result;
  }
}
