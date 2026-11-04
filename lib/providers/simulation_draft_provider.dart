import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/key_moment.dart';
import '../models/saved_simulation.dart';
import '../services/simulation_service.dart';
import 'simulation_providers.dart';

class SimulationDraft {
  static const defaultCapital = 10000;
  static const minCapital = 1000;
  static const maxCapital = 100000;
  static const capitalStep = 1000;
  static const defaultMonthlyAmount = 100;
  static const minMonthlyAmount = 20;
  static const maxMonthlyAmount = 1000;
  static const monthlyAmountStep = 10;
  static const percentStep = 5;

  final DateTime start;
  final SimulationMode mode;
  final Map<String, int> percents;
  final int capital;
  final int monthlyAmount;
  final int? savedId;
  final String? name;

  const SimulationDraft({
    required this.start,
    required this.mode,
    required this.percents,
    this.capital = defaultCapital,
    this.monthlyAmount = defaultMonthlyAmount,
    this.savedId,
    this.name,
  });

  int get totalPercent =>
      percents.values.fold(0, (sum, percent) => sum + percent);

  bool get isComplete => totalPercent == 100;

  bool get isMonthly => mode == SimulationMode.monthly;

  double get amount => (isMonthly ? monthlyAmount : capital).toDouble();

  Map<String, double> get weights => {
    for (final entry in percents.entries) entry.key: entry.value / 100,
  };

  SimulationDraft copyWith({
    DateTime? start,
    SimulationMode? mode,
    Map<String, int>? percents,
    int? capital,
    int? monthlyAmount,
  }) {
    return SimulationDraft(
      start: start ?? this.start,
      mode: mode ?? this.mode,
      percents: percents ?? this.percents,
      capital: capital ?? this.capital,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
    );
  }
}

class SimulationDraftNotifier extends Notifier<SimulationDraft> {
  @override
  SimulationDraft build() => _emptyDraft();

  SimulationDraft _emptyDraft() {
    return SimulationDraft(
      start: KeyMoment.all.first.date,
      mode: SimulationMode.lumpSum,
      percents: const {'spy_weekly': 50, 'gold_weekly': 30, 'bonds_weekly': 20},
    );
  }

  void startNew() {
    state = _emptyDraft();
  }

  void startWithAsset(String assetId) {
    state = SimulationDraft(
      start: KeyMoment.all.first.date,
      mode: SimulationMode.lumpSum,
      percents: {assetId: 100},
    );
  }

  void openPortfolio({
    required String name,
    required DateTime start,
    required Map<String, int> percents,
    required int capital,
  }) {
    state = SimulationDraft(
      start: start,
      mode: SimulationMode.lumpSum,
      percents: percents,
      capital: capital,
      name: name,
    );
  }

  void open(SavedSimulation simulation) {
    final isMonthly = simulation.mode == SimulationMode.monthly;
    final amount = simulation.amount.round();
    state = SimulationDraft(
      start: simulation.start,
      mode: simulation.mode,
      capital: isMonthly ? SimulationDraft.defaultCapital : amount,
      monthlyAmount: isMonthly ? amount : SimulationDraft.defaultMonthlyAmount,
      percents: {
        for (final entry in simulation.weights.entries)
          entry.key: (entry.value * 100).round(),
      },
      savedId: simulation.id,
      name: simulation.name,
    );
  }

  void setStart(DateTime start) {
    state = state.copyWith(start: start);
  }

  void setMode(SimulationMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setAmount(int amount) {
    state = state.isMonthly
        ? state.copyWith(monthlyAmount: amount)
        : state.copyWith(capital: amount);
  }

  void addAsset(String assetId) {
    state = state.copyWith(percents: {...state.percents, assetId: 0});
  }

  void removeAsset(String assetId) {
    state = state.copyWith(percents: {...state.percents}..remove(assetId));
  }

  void increase(String assetId) {
    if (state.totalPercent >= 100) return;
    _setPercent(
      assetId,
      state.percents[assetId]! + SimulationDraft.percentStep,
    );
  }

  void decrease(String assetId) {
    if (state.percents[assetId]! <= 0) return;
    _setPercent(
      assetId,
      state.percents[assetId]! - SimulationDraft.percentStep,
    );
  }

  void _setPercent(String assetId, int percent) {
    state = state.copyWith(percents: {...state.percents, assetId: percent});
  }
}

final simulationDraftProvider =
    NotifierProvider<SimulationDraftNotifier, SimulationDraft>(
      SimulationDraftNotifier.new,
    );

final draftResultProvider = FutureProvider.autoDispose((ref) {
  final draft = ref.watch(simulationDraftProvider);
  return ref
      .watch(simulationServiceProvider)
      .simulate(
        weights: draft.weights,
        start: draft.start,
        mode: draft.mode,
        amount: draft.amount,
      );
});
