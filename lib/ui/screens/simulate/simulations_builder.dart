import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/simulation_result.dart';
import '../../../providers/simulation_providers.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import 'simulator_widgets.dart';

class SimulationsBuilder extends ConsumerStatefulWidget {
  final List<SimulationRequest> requests;
  final Widget Function(List<SimulationResult> results) builder;
  final double loadingHeight;

  const SimulationsBuilder({
    super.key,
    required this.requests,
    required this.builder,
    this.loadingHeight = 260,
  });

  @override
  ConsumerState<SimulationsBuilder> createState() => _SimulationsBuilderState();
}

class _SimulationsBuilderState extends ConsumerState<SimulationsBuilder> {
  List<SimulationResult>? _lastResults;

  @override
  Widget build(BuildContext context) {
    final values = [
      for (final request in widget.requests)
        ref.watch(simulationProvider(request)),
    ];
    final failed = values.where((value) => value.hasError).firstOrNull;
    if (failed != null) {
      return ErrorView(message: simulationErrorMessage(failed.error!));
    }
    if (values.every((value) => value.hasValue)) {
      _lastResults = [for (final value in values) value.value!];
    }
    final results = _lastResults;
    if (results == null || results.length != widget.requests.length) {
      return SkeletonBox(height: widget.loadingHeight);
    }
    return widget.builder(results);
  }
}
