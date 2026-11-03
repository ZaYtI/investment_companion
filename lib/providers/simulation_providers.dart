import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/price_repository.dart';
import '../models/price_series.dart';
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
