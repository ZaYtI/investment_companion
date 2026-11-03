import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dca_options.dart';
import '../services/simulation_service.dart';
import 'simulation_providers.dart';

class DcaSettings {
  final DateTime start;
  final int monthlyAmount;
  final bool compareWithLumpSum;

  const DcaSettings({
    required this.start,
    required this.monthlyAmount,
    this.compareWithLumpSum = false,
  });

  DcaSettings copyWith({
    DateTime? start,
    int? monthlyAmount,
    bool? compareWithLumpSum,
  }) {
    return DcaSettings(
      start: start ?? this.start,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      compareWithLumpSum: compareWithLumpSum ?? this.compareWithLumpSum,
    );
  }
}

class DcaSettingsNotifier extends Notifier<DcaSettings> {
  final DcaOptions options;

  DcaSettingsNotifier(this.options);

  @override
  DcaSettings build() {
    return DcaSettings(
      start: options.defaultStart,
      monthlyAmount: options.defaultMonthly,
    );
  }

  void setStart(DateTime start) {
    state = state.copyWith(start: start);
  }

  void setMonthlyAmount(int amount) {
    state = state.copyWith(monthlyAmount: amount);
  }

  void setCompareWithLumpSum(bool compare) {
    state = state.copyWith(compareWithLumpSum: compare);
  }
}

final dcaSettingsProvider = NotifierProvider.autoDispose
    .family<DcaSettingsNotifier, DcaSettings, DcaOptions>(
      DcaSettingsNotifier.new,
    );

final dcaSimulationProvider = FutureProvider.autoDispose
    .family<DcaSimulation, DcaOptions>((ref, options) {
      final settings = ref.watch(dcaSettingsProvider(options));
      return ref
          .watch(simulationServiceProvider)
          .simulateDca(
            monthlyAssetId: options.assetId,
            lastPriceAssetId: options.lastPriceAssetId,
            start: settings.start,
            monthlyAmount: settings.monthlyAmount.toDouble(),
          );
    });
