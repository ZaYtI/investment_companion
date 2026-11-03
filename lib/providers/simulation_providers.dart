import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/price_repository.dart';
import '../models/price_series.dart';
import '../models/simulation_result.dart';
import '../services/simulation_service.dart';

final priceRepositoryProvider = Provider<PriceRepository>(
  (ref) => EmbeddedPriceRepository(),
);

final simulationServiceProvider = Provider<SimulationService>(
  (ref) => SimulationService(ref.watch(priceRepositoryProvider)),
);

final priceSeriesProvider = FutureProvider.family<PriceSeries, String>(
  (ref, id) => ref.watch(priceRepositoryProvider).getSeries(id),
);

class SimulationRequest {
  final Map<String, double> weights;
  final DateTime start;
  final DateTime? end;
  final double amount;

  const SimulationRequest({
    required this.weights,
    required this.start,
    this.end,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      other is SimulationRequest &&
      mapEquals(other.weights, weights) &&
      other.start == start &&
      other.end == end &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(weights.entries.map((e) => '${e.key}:${e.value}')),
    start,
    end,
    amount,
  );
}

final simulationProvider = FutureProvider.autoDispose
    .family<SimulationResult, SimulationRequest>(
      (ref, request) => ref
          .watch(simulationServiceProvider)
          .simulate(
            weights: request.weights,
            start: request.start,
            end: request.end,
            amount: request.amount,
          ),
    );
