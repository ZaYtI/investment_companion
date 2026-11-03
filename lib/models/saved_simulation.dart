import 'dart:convert';

import '../services/simulation_service.dart';

class SavedSimulation {
  final int? id;
  final String name;
  final DateTime start;
  final SimulationMode mode;
  final double amount;
  final Map<String, double> weights;
  final double invested;
  final double finalValue;
  final DateTime createdAt;

  const SavedSimulation({
    this.id,
    required this.name,
    required this.start,
    required this.mode,
    required this.amount,
    required this.weights,
    required this.invested,
    required this.finalValue,
    required this.createdAt,
  });

  double get performance => finalValue / invested - 1;

  factory SavedSimulation.fromMap(Map<String, Object?> map) {
    final weights =
        jsonDecode(map['weights'] as String) as Map<String, dynamic>;
    return SavedSimulation(
      id: map['id'] as int,
      name: map['name'] as String,
      start: DateTime.parse(map['start'] as String),
      mode: SimulationMode.values.byName(map['mode'] as String),
      amount: (map['amount'] as num).toDouble(),
      weights: weights.map(
        (asset, weight) => MapEntry(asset, (weight as num).toDouble()),
      ),
      invested: (map['invested'] as num).toDouble(),
      finalValue: (map['final_value'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
    'name': name,
    'start': start.toIso8601String(),
    'mode': mode.name,
    'amount': amount,
    'weights': jsonEncode(weights),
    'invested': invested,
    'final_value': finalValue,
    'created_at': createdAt.toIso8601String(),
  };
}
