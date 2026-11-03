import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/simulations_repository.dart';
import '../models/saved_simulation.dart';

final simulationsRepositoryProvider = Provider<SimulationsRepository>(
  (ref) => SimulationsRepository(),
);

class SavedSimulationsNotifier extends AsyncNotifier<List<SavedSimulation>> {
  SimulationsRepository get _repository =>
      ref.read(simulationsRepositoryProvider);

  @override
  Future<List<SavedSimulation>> build() => _repository.getAll();

  Future<int> add(SavedSimulation simulation) async {
    final id = await _repository.insert(simulation);
    state = AsyncData(await _repository.getAll());
    return id;
  }

  Future<void> remove(int id) async {
    await _repository.delete(id);
    state = AsyncData(await _repository.getAll());
  }
}

final savedSimulationsProvider =
    AsyncNotifierProvider<SavedSimulationsNotifier, List<SavedSimulation>>(
      SavedSimulationsNotifier.new,
    );
